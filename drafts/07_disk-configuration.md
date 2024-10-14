Title: Disk Configuration
Date: 2024-10-11T13:47:04
Category: NixOS

We've got two TODO lists; our general one:

- [x] Switch to flakes
- [ ] User configuration files
- [ ] Secrets
- [ ] More system packages

And the one keeping track of all the nasty manual configuration changes we've
made so far:

- [ ] Disk partitioning and formatting (needs flakes ✓)
- [ ] Root user password (needs secrets ✗)
- [ ] Wireless network connection details for `rentalflat` (needs secrets ✗)
- [ ] Passwords for `pindy` and `stooj` (needs secrets ✗)
- [ ] SSH known hosts file maybe. (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/` directory (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever (needs
      user configuration ✗)

OK, we've got flakes set up. Let's tackle declaratively declaring our disk... uhm... deal.

There's a tool for this, and it's flake-ready. [Disko](https://github.com/nix-community/disko). It's magical.

First of all, we're going to add it into our flake as an `input`:

<!-- TODO Link to commit 99b77f0 -->

The `inputs.nixpkgs.follows` is something we'll see a lot, and I'm not 100%
certain what it means yet. I _think_ it's something like "keep the nixpkgs in
this (imported disko) flake at the same version as the nixpkgs in the parent (my
flake.nix) flake".

Oh, and we need to then _output_ the disko module, so it will be part of the
generated configuration.

<!-- TODO Link to commit b5d2162 -->

Run a quick `sudo nixos-rebuild switch --flake .` and you'll get `disko` added
as an input:

```
[stooj@drummer:~/code/nix/nix-config]$ sudo nixos-rebuild switch --flake .
warning: updating lock file '/home/stooj/code/nix/nix-config/flake.lock':
• Added input 'disko':
    'github:nix-community/disko/6af4e02b9cf2a4126af542c9e299f13228cfe2e0' (2024-10-11)
• Added input 'disko/nixpkgs':
    follows 'nixpkgs'
building the system configuration...
activating the configuration...
setting up /etc...
reloading user units for stooj...
restarting sysinit-reactivation.target
the following new units were started: sysinit-reactivation.target, systemd-tmpfiles-resetup.service
```

The `flake.lock` file has been updated:

<!-- TODO Link to commit 1f580e3 -->

Now is the tricky bit: converting all that hand-made configuration from the
installation into disko/nix code.
I'm going to write these as separate commits so each change deals with a single
partition, but I wouldn't recommend `nixos-rebuild switch`-ing until all of the
changes are done.

Also, see that `Do not modify this file!` warning? Yeah, we're going to ignore
that...

First, make the FAT32 partition for `/boot`. Create a new file called
`disks.nix`:

```bash
cd ~/code/nix/nix-config
vim disks.nix
```

# References

- [disko/docs/HowTo.md - Installing NixOS module · nix-community/disko](https://github.com/nix-community/disko/blob/master/docs/HowTo.md#installing-nixos-module)
