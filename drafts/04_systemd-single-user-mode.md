Title: Systemd Single-user mode
Date: 2024-10-09T18:08:13
Category: System

Huh. I can't log into drummer. There are two options:

1. I used a different password to the one I thought I was using.
2. I typoed the password **twice**.

I somehow thing that #2 is more likely somehow, so we need to fix it.

Two options again:

1. Reinstall the OS. Will take a while, and is kinda cheating
2. Boot into single-user mode and reset the password.

Since I have local access to the laptop, option #2 is the way. I've done this
plenty times using GRUB, but we're not using GRUB on this laptop; we're using
systemd-boot.

According to [this StackExchange post](https://unix.stackexchange.com/a/773192),
it's a case of adding `single systemd.debug_shell` to the kernel init command.

If you haven't done this before, turn the machine on until you have a list of
boot entries (for us, it's different NixOS configurations 😍), then press the
`e` key to edit the top one.

All this stuff uses Emacs keybindings, so use `Ctrl-e` to move the cursor to the
end of the line, then append `single systemd.debug_shell` and press `Enter`.

This will boot you into a recovery shell and ask you for the root password
(which... I don't have). But if you `Ctrl+Alt+F9`, you can go to the 9th tty and
you'll find a shell session already logged in as root.

<!-- TODO Insert ultimate power gif -->

Then I used the following command to change my password, and was more careful
about typing it this time:

```bash
passwd stooj
```

# References

- [Proper way to start a shell in single user mode under systemd? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/773025/proper-way-to-start-a-shell-in-single-user-mode-under-systemd)
- [systemd-debug-generator man page](https://www.freedesktop.org/software/systemd/man/latest/systemd-debug-generator.html)
- [Moving Point (GNU Emacs Manual)](https://www.gnu.org/software/emacs/manual/html_node/emacs/Moving-Point.html)
