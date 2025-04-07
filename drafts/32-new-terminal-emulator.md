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
