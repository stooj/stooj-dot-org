Title: XDG user directories
Date: 2024-11-25T22:08:15
Category: NixOS

I like my home directory to be neat and ordered and as uncluttered as I can make it. If I can put config into the `~/.config` directory, that's where it should go. State? Well that should go in `~/.local/state`. Cache? `~/.cache` of course!

I also like my user-facing directories to be called a certain thing, and lowercased. I made this decision a long time ago in an effort to make my Shift keys last a little longer, and I've been fighting every OS on it ever since. Dunno why, but they all love their capitalized directory names.

I do not.

It's easy to solve with home-manager though.

```bash
cd ~/code/nix/nix-config
git checkout -b xdg-user-dirs
```

First off, setting up [XDG base directory](https://wiki.archlinux.org/title/XDG_Base_Directory) env vars. It's as simple as:

<!-- TODO Link to commit 38eb3e5 -->

At least, it should be...

```bash
echo $XDG_CACHE_HOME
```

Nada. Oh, it's probably because bash is not being managed by home-manager yet. That can go in the later basket.

But I can create all my precious home directories.



# References

- [XDG user directories - ArchWiki](https://wiki.archlinux.org/title/XDG_user_directories)
- [Filesystem Hierarchy Standard - NixOS4Noobs](https://jorel.dev/NixOS4Noobs/fhs.html)
- [XDG Base Directory - ArchWiki](https://wiki.archlinux.org/title/XDG_Base_Directory)
- [home-manager/modules/misc/xdg.nix at master · nix-community/home-manager · GitHub](https://github.com/nix-community/home-manager/blob/master/modules/misc/xdg.nix)
