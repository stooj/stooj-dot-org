Title: vim
Date: 2025-04-15T22:30:20
Category: NixOS

```bash
cd ~/code/nix/nix-config
git checkout -b vim
```

This is going to be a big one.

A couple of posts ago I mucked around getting a single plugin installed in the system configuration of vim. It was a bit of a footer and I'd like to leave `root`s vim as plain as possible for security & performance reasons; if I'm using vim as root something has gone wrong somewhere and I'm in crisis mode.

My _user_ vim configuration is a different matter, though. I want two configurations; my standard full-blown bells-and-whistles all-singing-all-dancing basically-an-ide vim configuration for workstations, and then a subset of plugins and configuration for use on servers. On a workstation the configuration should also apply to the gui version of vim. Oh, and it's going to be neovim rather than vim.

My plan is not to _completely_ finish my vim configuration but at least get a nice system that can be easily added to in future.

Neovim has a respectable set of configuration options in [home manager](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.enable), but the configuration would still end up being a lot of vim script or lua shoved into nix's [multi-line strings](https://nix.dev/manual/nix/2.18/language/values#type-string). And there is another project out there.

[NixVim - A Neovim configuration system for nix](https://nix-community.github.io/nixvim/)

Installation first. It's accessible as a flake ([docs](https://nix-community.github.io/nixvim/24.11/user-guide/install.html)).

<!-- TODO Link to commit 1c94a4e -->

Then update the flake.lock file with:

```bash
nix flake update
```

This updates the `flake.lock` file:

<!-- TODO Link to commit 5f0b3bd -->

So `vim` isn't going to be the system default any more. :thinking: I want it as the default for the _root_ user, and pindy will probably want something else, so [line 5 of `vim.nix`](https://github.com/stooj/nix-config/blob/a676e03640450c38b25c2303ae11abce05abd413/vim.nix#L5) probably doesn't make sense any more. The question is: "how do I set the default for the root user? Do I manage the root user with home manager as well?"

Ugh, that means I need to either rethink `common`, or just decide that `common` isn't included for the root user. They will have minimal configuration anyway...

It's a problem for another day, right now I'll just remove it.

<!-- TODO Link to commit fba3b95 -->

This configuration is going to be in multiple parts, and kinda big, so I'm going to try to logically split it up. First step is to create a directory structure for the configuration and install neovim. Pindy doesn't use any kind of vi derivative so this will all live in `stooj`.

<!-- TODO Link to commit 1fed42c -->

Vim is still installed as a system package and if I'm in my user account I want `vim` to be an alias for `nvim`:

```
[stooj@drummer:~/code/nix/nix-config]$ readlink --canonicalize $(which vim)
/nix/store/ci04zrl659f8ci0ixps2nwr8nq4l08c0-vim-9.1.1122/bin/vim

[stooj@drummer:~/code/nix/nix-config]$ readlink --canonicalize $(which nvim)
/nix/store/31gmcik98f8bgl3blgy2i2dky87hfhnn-neovim-0.10.2/bin/nvim
```

<!-- TODO Link to commit 189de49 -->

```
[stooj@drummer:~]$ readlink --canonicalize $(which vim)
/nix/store/kjybnyrqdis57yv4qfprycd1xcqw44ky-neovim-0.10.2/bin/nvim

[stooj@drummer:~]$ readlink --canonicalize $(which nvim)
/nix/store/kjybnyrqdis57yv4qfprycd1xcqw44ky-neovim-0.10.2/bin/nvim
```

Be right back. Restarting my editor.

```vim
:wq
```

<!-- TODO Insert image 34-new_neovim_installation.png -->

Time to get config-ing.

Line numbers first, and if you're not a vim user then an "unusual" setup straight out the gate.

The current line number is shown at the bottom a {,neo}vim window by default, along with the column number as well. That's handy, but I like to have the line numbers be a bit more obvious for myself and anyone looking over my shoulder.

<!-- TODO Link to commit 46ffc6c -->

We have line numbers. Wow, they're a bit difficult to see by default, huh?

<!-- TODO Insert image 34-neovim_with_line_numbers.png -->

> !Note
> I can't get over how cool kitty's hint thing is. Yanking commit hashes and filenames is *so* easy 😍

Uuughh... I didn't want to do this yet, but I need to. I can barely see the line numbers with the default colourscheme, so I need to change it. I do quite _like_ the defaults; its muted and chill, but the line numbers are muted so much they are basically invisible for me.

<!-- TODO Link to commit d2a6446 -->

<!-- TODO Insert image 34-neovim_with_gruvbox.png -->

That's better. It's still a little bit muted for all this sunshine I'm living in though.

Lets line up all three and see what they look like:

<!-- TODO Insert image 34-gruvbox_default.png -->
<!-- TODO Insert image 34-gruvbox_soft.png -->
<!-- TODO Insert image 34-gruvbox_hard.png -->

The hard's have it, but that turns out to be the default.

Oooh! What's `dim_inactive` though (from [the plugin readme](https://github.com/ellisonleao/gruvbox.nvim))?

<!-- TODO Insert image 34-gruvbox_no_dim.png -->
<!-- TODO Insert image 34-gruvbox_with_dim.png -->

Oooh, I like that!

<!-- TODO Link to commit 522c468 -->

Inactive windows will have gruvbox `soft`, active windows will use gruvbox `hard`.

I promised a strange configuration, and this all looks pretty normal so far. Here you go:

<!-- TODO Link to commit 1b97f07 -->

<!-- TODO Insert image 34-neovim_with_relative_numbers.png -->

With `relativenumber`, the _actual_ line number **only** shows on the line where the cursor is. The line above is "1", or "1 line above where you are at the moment". This means it's trivial to jump 6 lines up (`6k`) rather than going to line three (`:3`). It doesn't gain you much in such a small file but it's great for larger ones, and my brain thinks in these relative terms about line numbers. It makes it easier to count how many lines to delete or select or something too, although you have to remember to add 1 to the relative number shown (because you need to include the current number).

Anyway, something urgent has come up. I haven't set neovim as my default editor yet. Easily fixed.

<!-- TODO Link to commit f8dabc6 -->

While I'm here, I might as well set it as the default for `vimdiff` as well.

<!-- TODO Link to commit 46782a0 -->

I don't think I like the layout here though, I'd like `default.nix` to be an entrypoint for the configuration rather than having configuration itself.

Something like this:

<!-- TODO Link to commit 92e2b57 -->

Where to start? Lets make it easy to learn the things I'm going to configure by making the keybindings obvious with [which-key](https://github.com/folke/which-key.nvim), which shows a reference for keybindings as you type them. It's a utility thing, so I'm going to take a page out of [dc-tec's nixvim config](https://github.com/dc-tec/nixvim/tree/main) and make a `plugins/utils` directory.

Here's how you install a plugin with nixvim. How fecking cool and easy is that?

<!-- TODO Link to commit e9cc911 -->

TODO: Take a screenshot of `which-key` (try just a `g` command)

- whichkey ✓
- fuzzy finding
- git plugins
- surround
- matching brackets
- rainbow brackets
# References

- [programs.neovim - Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.enable)
- [Data Types - Nix Reference Manual](https://nix.dev/manual/nix/2.18/language/values#type-string)
- [Home - nixvim docs](https://nix-community.github.io/nixvim/)
- [Installation - nixvim docs](https://nix-community.github.io/nixvim/24.11/user-guide/install.html)
- [ellisonleao/gruvbox.nvim: Lua port of the most famous vim colorscheme](https://github.com/ellisonleao/gruvbox.nvim)
- [folke/which-key.nvim: 💥 Create key bindings that stick. WhichKey helps you remember your Neovim keymaps, by showing available keybindings in a popup as you type.](https://github.com/folke/which-key.nvim)
- [dc-tec/nixvim: My personal NixVim Configuration](https://github.com/dc-tec/nixvim/tree/main)
