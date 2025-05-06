Title: A gui for vim
Date: 2025-05-04T21:30:55
Category: NixOS

Every now and then I need a version of neovim that is wrapped in a gui application. I'd like neovim please, using the same configuration as my usual terminal-based one. There are [a lot of them](https://github.com/neovim/neovim/wiki/Related-projects#gui).

```bash
cd ~/code/nix/nix-config/
git checkout -b gui-for-vim
```

I'm going to try out [Neovide](https://neovide.dev/) because it's just before neovim in the [home-manager appendix](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovide.enable) so I thought I'd try it out.

[firenvim](https://github.com/glacambre/firenvim) looks really interesting though for when I start using Firefox.

<!-- TODO Link to commit 7d10f80 -->

That doesn't build though 🤔

```
error: The option `home-manager.users.stooj.programs.neovide.settings' was accessed but has no value defined. Try setting the option.
```

That must be a bug, so I [opened one](https://github.com/nix-community/home-manager/issues/6982). In the mean time, it's easy enough to add some settings.

Add a setting:

<!-- TODO Link to commit 40a4616 -->

I don't like that though; it's relying on the `$PATH` variable to discover where nvim is. Hmm, how do you grab the nixvim binary path outside of the nixvim configuration?

Maybe using `lib.getExe` like this?

<!-- TODO Link to commit 41ee12c -->

What does that give me?

```bash
cat ~/.config/neovide/config.toml | grep neovim-bin
neovim-bin = "/nix/store/f9shhl3fj8x6ii1zygb2waj56n545brr-neovim-0.10.2/bin/nvim"
```

Is `/nix/store/f9shhl3fj8x6ii1zygb2waj56n545brr-neovim-0.10.2/bin/nvim` the `nvim` that `nixvim` creates?

```bash
readlink --canonicalize $(which nvim)
/nix/store/1wnsfz5kja7whz2dvqa3b8bgysdis2hn-neovim-0.10.2/bin/nvim
```

No, they are different. How about `programs.nixvim.package`? That's probably the package before nixvim does it's wrapping stuff, but worth a try...

<!-- TODO Link to commit bbae6a7 -->

I was guilty of a [useless use of cat](https://porkmail.org/era/unix/award#cat) before, time to fix that:

```bash
grep neovim-bin ~/.config/neovide/config.toml
neovim-bin = "/nix/store/j28bnn9bjn4wf8zlhw3lddfk42p4f0i8-neovim-unwrapped-0.10.2"
```

OK, that's different. Is it the same as the command I run when I type `vim`?

```bash
readlink --canonicalize $(which vim)
/nix/store/1wnsfz5kja7whz2dvqa3b8bgysdis2hn-neovim-0.10.2/bin/nvim
```

Nope.

There's a section of the nixvim manual called [build](https://nix-community.github.io/nixvim/24.11/NeovimOptions/build/index.html), what's that.

Oh! `build.package`! That looks perfect.

<!-- TODO Link to commit fd5ec50 -->

Let's do the check in a one-liner this time. Grep the config, split it on the `=` and get the second part, then use `xargs` to trim the whitespace and remove the quotes:

```bash
grep neovim-bin ~/.config/neovide/config.toml | cut -d = -f2 | xargs && readlink --canonicalize $(which vim)
/nix/store/1wnsfz5kja7whz2dvqa3b8bgysdis2hn-neovim-0.10.2
/nix/store/1wnsfz5kja7whz2dvqa3b8bgysdis2hn-neovim-0.10.2/bin/nvim
```

Brilliant! We're _so close_!

How about I combine two of my approaches?

<!-- TODO Link to commit eaab32e -->

```bash
grep neovim-bin ~/.config/neovide/config.toml | cut -d = -f2 | xargs && readlink --canonicalize $(which vim)
/nix/store/1wnsfz5kja7whz2dvqa3b8bgysdis2hn-neovim-0.10.2/bin/nvim
/nix/store/1wnsfz5kja7whz2dvqa3b8bgysdis2hn-neovim-0.10.2/bin/nvim
```

Yay, we did it!

And neovide opens, and of course is gruvbox coloured. Lovely. It's very **big** though.

The [example `programs.neovide.settings`](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovide.settings) option has a `font` declaration, but it'd be nice if I could _change_ the size using the same keybinds as you'd use in Kitty or Firefox or something (the `ctrl +` and `ctrl -` keys). Luckily there's a neovide [scale](https://neovide.dev/configuration.html#scale) option and a [nifty recipe of keybinds](https://neovide.dev/faq.html#how-can-i-dynamically-change-the-scale-at-runtime). This'll go into the neovim configuration though.

<!-- TODO Link to commit c15fb51 -->

Now if you hold ctrl and press the `+` or `-` keys, neovide will scale up and down. Though It's still big, I think I need the base scale fixed a bit.

Or just set the font size:

<!-- TODO Link to commit 8dfa455 -->

That's better. Is 8 the default for kitty too? Either way, it looks about the same in both:

<!-- TODO Insert image 39-neovide_nvim_comparison.png -->

Hmm, the _spacing_ is different though. Hmm, 7 is slighly _smaller_ than in kitty.

<!-- TODO Link to commit a28a1f2 -->

<!-- TODO Insert image 39-neovide_nvim_comparison_2.png -->

Och well, close enough.

One last thing to do is to ask Qutebrowser to use neovide for text edit boxes. This is cool when it works; you go into insert mode in a text field in Qutebrowser and press `<ctrl+e>`, and qutebrowser will open a gui vim program (`gvim` by default) and let you edit the text field sensibly. Unfortunately it doesn't work with a lot of javascript-"enhanced" text fields :(.

But it works on GitHub, for example.

<!-- TODO Link to commit 35dbc3c -->

This works by qutebrowser opening a file in `/tmp` and sending it to `neovide` (the `{}` is replaced with the file path). Because `neovide` is opened with `--no-fork` qutebrowser can just wait for the process to end. When the process end it can read in the content of that temp file into the html input box.

But that `neovide` string isn't the nix way.

Before:

```bash
grep editor ~/.config/qutebrowser/config.py
c.editor.command = ["neovide", "--no-fork", "{}"]
```

<!-- TODO Link to commit d65c15a -->

After:

```bash
grep editor ~/.config/qutebrowser/config.py
c.editor.command = ["/nix/store/9m347qikyk5zb473d7rsasmpw6jri1ma-neovide-0.13.3/bin/neovide", "--no-fork", "{}"]
```

```bash
cd ~/code/nix/nix-config
git checkout main
git merge gui-for-vim
```

# References

- [Related projects · neovim/neovim Wiki](https://github.com/neovim/neovim/wiki/Related-projects#gui)
- [Neovide - Neovide](https://neovide.dev/)
- [Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovide.enable)
- [glacambre/firenvim: Embed Neovim in Chrome, Firefox & others.](https://github.com/glacambre/firenvim?tab=readme-ov-file)
- [bug: programs.neovide requires `settings` · Issue #6982 · nix-community/home-manager](https://github.com/nix-community/home-manager/issues/6982)
- [Useless Use of Cat Award](https://porkmail.org/era/unix/award#cat)
- [build - nixvim docs](https://nix-community.github.io/nixvim/24.11/NeovimOptions/build/index.html)
- [Configuration - scale - Neovide](https://neovide.dev/configuration.html#scale)
- [FAQ - How can I dynamically change the scale at runtime? - Neovide](https://neovide.dev/faq.html#how-can-i-dynamically-change-the-scale-at-runtime)
- [Configuration - Neovide](https://neovide.dev/configuration.html#font)
