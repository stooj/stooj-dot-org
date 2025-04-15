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

# References

- [programs.neovim - Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.enable)
- [Data Types - Nix Reference Manual](https://nix.dev/manual/nix/2.18/language/values#type-string)
- [Home - nixvim docs](https://nix-community.github.io/nixvim/)
- [Installation - nixvim docs](https://nix-community.github.io/nixvim/24.11/user-guide/install.html)
