Title: Activate Home Manager
Date: 2024-11-13T20:37:13
Category: NixOS

As usual, start with my TODO list:

At the end of the OS installation, we had two TODO lists to check:

- [x] Switch to flakes
- [ ] User configuration files
- [x] Secrets
- [ ] More system packages (like a working desktop)
- [ ] User secrets

We also had a list of things to add to the configuration:

- [x] Disk partitioning and formatting (needs flakes ✓)
- [x] Root user password (needs secrets ✓)
- [x] Wireless network connection details for `rentalflat` (needs secrets ✓)
- [x] Passwords for `pindy` and `stooj` (needs secrets ✓)
- [ ] SSH known hosts file maybe. (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/` directory (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever (needs
      user configuration ✗)
- [ ] Git user configuration (needs user configuration ✗)
- [ ] GPG pubring (needs user configuration ✗)

My laptop still isn't particulary useful yet, but I'm still in the bootstrap
phase which involves ticking off all the items above 👆, and the biggest-impact
change looks like User Configuration.

The way of managing user configuration files with Nix is using [Home Manager](https://nix-community.github.io/home-manager/index.xhtml#ch-introduction).
It lets you reproduce the configuration of a home directory (say `/home/stooj`).

What baffles me is that the official installation instructions include adding a
nix channel, which **is a stateful thing to do**! It's not part of the
configuration stored in the git repo so it won't get applied when I recreate the
system. This feels pretty anti-patternish to me.

You can add it to the flake as well though, which is "the right way™" if you ask
me.

Here's how:

<!-- TODO Link to commit 94f2370 -->

The `follows` here (and in the sops configuration) means "keep in sync with
nixpkgs", presumably in case `release-24.05` drifts from `nixos-24.05`.

Out of the box, home-manager uses it's own instance of `pkgs`, but I want it to
use the system pkgs rather than a per-user copy. It's faster.

<!-- TODO Link to commit fb1f23a -->

The other thing home-manager does is put all the installed packages into
`$HOME/.nix-profile`. That's fine by me, but according to the [docs](https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module)
it breaks building VMs, which is probably going to be handy in the future. So
time to change it so packages get installed in `/etc/profiles/per-user/stooj`.

<!-- TODO Link to commit 05d078b -->

Next it's time to add user configurations for stooj and pindy. I'm splitting
each user into a separate file, and this commit is just boiler plate "turn
things on" stuff.

<!-- TODO Link to commit d3fdb4c -->

It'll start a couple of systemd services:

- home-manager-pindy.service
- home-manager-stooj.service
- nix-daemon.service

`nix-daemon` runs build tasks and other stuff on behalf of unprivileged users,
which seems pretty important for managing user configurations.

I'm a bit hazy on this next step - this option is nested **inside** the user's
configuration, so do I need to set it for each user? Or do I only need to set it
once? I guess home-manager is installed for each user, so it needs to be set for
each user.

Anyway, this option tells home-manager to install and manage itself.

<!-- TODO Link to commit 2fb3885 -->

Woah. That was easy. And the options are [many and varied](https://nix-community.github.io/home-manager/options.xhtml).

- [x] Switch to flakes
- [x] User configuration files
- [x] Secrets
- [ ] More system packages (like a working desktop)
- [ ] User secrets

Time to try this out with something interesting.

<!-- TODO Maybe email? -->

# References

- [Getting Started with Home Manager | NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/start-using-home-manager)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml)
