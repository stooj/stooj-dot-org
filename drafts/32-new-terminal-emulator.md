Title: A new terminal emulator
Date: 2025-04-07T22:17:35
Category: NixOS

```bash
cd ~/code/nix/nix-config
git checkout -b new-terminal-emulator
```

> That'll do for hardware tweaks just now. It's time to switch out xterm for alacritty and get a nicer shell prompt. 

Or maybe it's time to try [kitty](https://sw.kovidgoyal.net/kitty/index.html) again. Terminal emulators are pretty well represented in Home Manager so that's where I'm going to configure them. It's another shared config betwen pindy and me as well. Here's the empty configuration to start with:

<!-- TODO Link to commit 04878bd -->

And enable kitty:

<!-- TODO Link to commit 5e61548 -->

i3wm uses `i3-sensible-terminal` to decide which terminal to use as the preferred one, but `kitty` is [way down in the list of preferences](https://man.archlinux.org/man/i3-sensible-terminal.1) (below xterm) so it needs to be set as the preferred option with an env var (`$TERMINAL`). The thing is, I want to *share* this configuration with pindy, but she prefers [`Terminator`](https://gnome-terminator.org/) to... well, anything else. Yay! Lots of GNOME dependencies.

So I'm going to push individual preferences into a file per-user.

<!-- TODO Link to commit e6f422d -->

This didn't work though, the env var isn't set even if I open a new terminal (still xterm). According to the [source](https://github.com/nix-community/home-manager/blob/a4d8020820a85b47f842eae76ad083b0ec2a886a/modules/systemd.nix#L92) the var is set in `~/.config/environment.d/10-home-manager.conf`. Maybe it's only sourced at boot? Be right back after one of those turn it off and turn it on tactics.

Nope. Still no. Maybe my issue here is that I'm still running X, so the systemd variables don't actually influence things?

There's also [`home.sessionVariables`](https://nix-community.github.io/home-manager/options.xhtml#opt-home.sessionVariables), maybe that'll do it?

<!-- TODO Link to commit a13efef -->

According to [that source](https://github.com/nix-community/home-manager/blob/a4d8020820a85b47f842eae76ad083b0ec2a886a/modules/home-environment.nix#L591), it'll go into `/etc/profile.d/hm-session-vars.sh`. It looks like it only sources the session vars **once** per boot with that `__HM_SESS_VARS_SOURCED=1` line. But it doesn't exist for me :confused:. Ah, it's in `/etc/profiles/per-user/stooj/etc/profile.d/hm-session-vars.sh` - that makes sense, it'd need to be different for each user and the path in the source code is actually relative to the home-manager profile.

Definitely only being sourced once. Time for another reboot (that's a bit of a pain).

Oh, it was worth it though. Kitty is beautiful.

<!-- TODO insert 32-kitty_terminal.png -->

One thing I really want from kitty that alacritty can do out of the box is opening URLs in the default browser. According to the [Hints](https://sw.kovidgoyal.net/kitty/kittens/hints/) page it does this with `Ctrl+Shift+e`. 

<!-- TODO insert 32-kitty_url_hints.png -->

Woah, that works really well. See the green numbers?

The other default hints are documented [here](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Open-URL).

The other thing that kitty can do apparently is opening the scrollback buffer in vim according to [this reddit post](https://www.reddit.com/r/KittyTerminal/comments/t5skn8/comment/hza18au/).

<!-- TODO Link to commit e5ac2d4 -->

You open the scrollback buffer using `Ctrl+Shift+h`.

Ugh, it looks rubbish though.

<!-- TODO insert 32-kitty_url_hints.png -->

It's because vim doesn't understand those ansi code sequences. There's a [vim plugin though](https://github.com/powerman/vim-plugin-AnsiEsc) that will apparently fix it.

Time to install a vim plugin. The first of many probably.

Wait, time to get the vim configuration out of the top-level `configuration.nix` file.

<!-- TODO Link to commit e336a98 -->

Uhm, it's not packaged though, so I'm going to need to build it. The instructions are on the [vim wiki page](https://nixos.wiki/wiki/Vim).

First, `programs.vim` doesn't support plugins. So I need to switch to the more generic management (install this package and override it), and add an environment variable that does the same as `defaultEditor = true;`. This customization needs `vimrcConfig.customRC` as well, so I've put in a `set number` option to check that it's working correctly.

It is.

I'm going to need some more stuff in `vimrcConfig`, so here's a commit that rearranges that to minimize the diffs:

<!-- TODO Link to commit 3f5707b -->

That commit doesn't _change_ anything, it's just cosmetic. Here's the real change; building the plugin:

<!-- TODO Link to commit d61667f -->

There's a lot to explain here, so I'm going to go to bed and do it tomorrow.

Good morning!

OK, at the top of this change is a [let expression](https://nixos.org/guides/nix-pills/04-basics-of-language#let-expressions), which _lets_ you (:grin:) define variables that can be referenced inside the body of a nix expression. Those variables will only be available in the scope of the `in` bit.

I'm declaring a variable called `vim-ansi-esc` which contains the build derivation of the `vim-plugin-AnsiEsc` vim plugin. `buildVimPlugin` clones a repo from GitHub, builds it like a normal vim plugin and then it's referenced in the `vim-ansi-esc` variable.

Then I include that plugin as part of the `vim_configurable` customization; the `start` bit is "put this in vim's `pack/*/start` configuration so it can be found by vim.

NOTE: the hash is the latest commit hash [according to GitHub](https://github.com/powerman/vim-plugin-AnsiEsc/commits/master/). I don't know of a good way of calculating the sha256 sum other than putting a nonsense value in first, trying to build it, and then correcting it based on the error message: e.g.:

```
error: hash mismatch in fixed-output derivation '/nix/store/x0pxbj9sy48mrc6vv5cfxphypiwyazv8-source.drv':
         specified: sha256-cy3R/cHrY0o1oDEnxzhoL4L2Tncfmh6ANX9H1ZEKgII=
            got:    sha256-N7UVzk/XUX76XcPHds+lLMZzO7gahj/9LIfof2BPThc=
```

Hey! After a `nix-rebuild` the plugin is there! Neat! Very exciting.

I probably want the scrollback buffer to be read-only as well by default:

<!-- TODO Link to commit 40dbafd -->

AnsiEsc still doesn't work for the kitty scrollback though, because it's `pkgs.vim` is not the same as the systemPackages `pkgs.vim_configurable`. How about this?

<!-- TODO Link to commit b70bde7 -->

No, still not correct. Let's see:

```bash
echo -n "Vim with AnsiESC is here: " && \
    readlink $(which vim)
```

```
Vim with AnsiESC is here: /nix/store/0fikza1prd3gfh50ypchwd32gi3zhllg-vim/bin/vim
```

```bash
echo -n "Kitty is using vim from: " && \
    cat ~/.config/kitty/kitty.conf | grep scrollback_pager | cut -f2 -d' '
```

```
Kitty is using vim from: /nix/store/72z2dbd9rvzqjikh88hszc1mmxpx8wyx-vim-full-9.1.1046/bin/vim
```

Those are **not** the same.
Also, the kitty thing doesn't work because pkgs.vim in home-manager isn't pointing to the same package. It's using the `vim` package

TODO: Tidy up qutebrowser
# References
- [kitty](https://sw.kovidgoyal.net/kitty/index.html)
- [kitty - ArchWiki](https://wiki.archlinux.org/title/Kitty)
- [Frequently Asked Questions - kitty](https://sw.kovidgoyal.net/kitty/faq/)
- [Kitty is incredible !!! : r/KittyTerminal](https://www.reddit.com/r/KittyTerminal/comments/t5skn8/comment/hza18au/?rdt=52798)
- [Home Manager - Options - kitty.enable](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.kitty.enable)
- [i3-sensible-terminal(1) — Arch manual pages](https://man.archlinux.org/man/i3-sensible-terminal.1)
- [Overview | Terminator Terminal Emulator](https://gnome-terminator.org/)
- [Home Manager - Options - systemd.user.sessionVariables](https://nix-community.github.io/home-manager/options.xhtml#opt-systemd.user.sessionVariables)
- [Home Manager - Options - home.sessionVariables](https://nix-community.github.io/home-manager/options.xhtml#opt-home.sessionVariables)
- [Hints - kitty](https://sw.kovidgoyal.net/kitty/kittens/hints/)
- [Overview - The scrollback buffer - kitty](https://sw.kovidgoyal.net/kitty/overview/#the-scrollback-buffer)
- [powerman/vim-plugin-AnsiEsc: ansi escape sequences concealed, but highlighted as specified (conceal)](https://github.com/powerman/vim-plugin-AnsiEsc)
- [Vim - NixOS Wiki](https://nixos.wiki/wiki/Vim)
- [The Basics of the Language - Let expressions - Nix Pills](https://nixos.org/guides/nix-pills/04-basics-of-language#let-expressions)
- [Nixpkgs Overriding Packages - Nix Pills](https://nixos.org/guides/nix-pills/17-nixpkgs-overriding-packages.html)
- [plugin system - how to load vim8 optional packages in vimrc? - Vi and Vim Stack Exchange](https://vi.stackexchange.com/questions/20810/how-to-load-vim8-optional-packages-in-vimrc/20818#20818)
