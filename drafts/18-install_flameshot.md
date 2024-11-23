Title: Install Flameshot for screen captures
Date: 2024-11-23T20:27:02
Category: NixOS

This blog has been sorely lacking in pretty pictures so far, so I want to make it easy to take screen captures.

There are two million, three hundred and sixty eight different screenshot utilities so any preference I have for one tool over the other is a bit arbitrary.

I'm going to use [Flameshot](https://flameshot.org/) because it's already [configurable with home-manager](https://nix-community.github.io/home-manager/options.xhtml#opt-services.flameshot.enable), it lets you pick a directory to save things to by default, and you get to draw arrows over your captures before you save them.

```bash
cd ~/code/nix/nix-config
git checkout -b flameshot
```

First off, enable the service.

<!-- TODO Link to commit 1568b87 -->

It didn't work. 🤔 Looking at [the home-manager source](https://github.com/nix-community/home-manager/blob/16fe78182e924c9a2b0cffa1f343efea80945ef2/modules/services/flameshot.nix#L66) it creates a systemd user service called flameshot.

```bash
systemctl --user status flameshot.service
```

```
○ flameshot.service - Flameshot screenshot tool
     Loaded: loaded (/home/stooj/.config/systemd/user/flameshot.service; enabled; pres>
     Active: inactive (dead)
```

That's not right. Were there any logs?

```bash
journalctl --user --unit flameshot.service
```

```
-- No entries --
```

No.

What happens if I just start it manually?

```bash
systemctl --user start flameshot.service
```

```
Failed to start flameshot.service: Unit tray.target not found
```

`tray.target`? What's that?

```bash
systemctl --user status tray.target
```

```
Unit tray.target could not be found.
```

It's something I don't have. That's a bug. To the issue tracker!

Here it is: [Unit tray.target not found · nix-community/home-manager#2064](https://github.com/nix-community/home-manager/issues/2064), and there's [a workaround](https://github.com/nix-community/home-manager/issues/2064#issuecomment-887300055).

<!-- TODO Link to commit 19b2f9f -->

It didn't start when I applied this config, maybe because it's not really linked to trigger a reload of the service when I make up a new one that seems unrelated?

Try it manually:

```bash
systemctl --user start flameshot.service
systemctl --user status flameshot.service
```

```
○ flameshot.service - Flameshot screenshot tool
     Loaded: loaded (/home/stooj/.config/systemd/user/flameshot.service; enabled; pres>
     Active: inactive (dead) since Sat 2024-11-23 21:59:24 CET; 2s ago
   Duration: 70ms
    Process: 3728 ExecStart=/nix/store/k06qwp7d836gkmz1qjzzgl6fcc2bdd99-flameshot-12.1>
   Main PID: 3728 (code=exited, status=0/SUCCESS)
        CPU: 28ms

Nov 23 21:59:24 drummer systemd[1814]: Started Flameshot screenshot tool.

```

Hurray. I'm going to try a reboot as well just to make sure it comes up correctly (I'm worried about [this comment](https://github.com/nix-community/home-manager/issues/2064#issuecomment-1845060397))

```bash
reboot
sudo !!
# Whoops
```

Hurrah! Flameshot is in the tray. It needs a bit of configuration tweaking though (using [the upstream example](https://github.com/flameshot-org/flameshot/blob/729f494d535356adfbd65dc127a5c82ea218006e/flameshot.example.ini) as a reference):

<!-- TODO Link to commit 5d54d6a -->

1. The default tool line thickness is too thin to be useful. I like LOUD arrows.
2. I take a lot of screenshots so I want the seconds in the filename as well as hours and minutes.
3. png as the default output.
4. Always save the file to... uh... wait... that's not going to work. It doesn't exist yet 😭
5. Fix the save path. Uh. What does that mean?
6. Don't show annoying pop up alerts that tell me how to use the tool. You don't use the system's notifications, so I can't use my keyboard to get rid of them and they look bad.
7. Don't launch at startup, systemd is taking care of that (now).

I'm pulling the location of my home directory from `config.home.homeDirectory` rather than hard-coding it. Maybe one day in the future it'll change or I'll change my username or something. **Anything** could happen.

But that directory definitely does not exist yet, so we have to create it somehow. Ugh, I think that will be surprisingly difficult, so I'm going to punt it and resurrect that TODO list:

- [x] Disk partitioning and formatting
- [x] Root user password
- [x] Wireless network connection details for `rentalflat`
- [x] Passwords for `pindy` and `stooj`
- [x] SSH known hosts file maybe.
- [x] `/home/stooj/code/nix/` directory
- [x] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever
- [x] Git user configuration
- [x] GPG pubring
- [ ] Create `~/pictures/screenshots`

For now, it's ugly hack time:

```bash
mkdir --parents ~/pictures/screenshots
```

I need to hook it up to some keybindings now, so back to the i3 config:

<!-- TODO Link to commit 20db7c8 -->

Three keybindings:

1. Print Screen key takes a screen capture of the whole screen
2. Meta key and Print Screen lets me drag a box over the thing I want to capture
3. Meta key and Shift and Print Screen has a wee script which waits 5 seconds and then lets me drag a box over the thing I want to capture. It also sends a notification count-down every second. I use this **all the time**.


# References

- [Flameshot | Open Source Screenshot Software](https://flameshot.org/)
- [services.flameshot](https://nix-community.github.io/home-manager/options.xhtml#opt-services.flameshot.enable)
- [Unit tray.target not found · Issue #2064 · nix-community/home-manager](https://github.com/nix-community/home-manager/issues/2064)
- [flameshot.example.ini](https://github.com/flameshot-org/flameshot/blob/729f494d535356adfbd65dc127a5c82ea218006e/flameshot.example.ini)
