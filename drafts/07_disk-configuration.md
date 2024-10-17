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

And add some boilerplate. `nvme` is a name, it could be anything. Call it
bananas for all I care.

<!-- TODO Link to commit a2610db -->

I mentioned back in <!-- TODO Add link to wherever I talked about disk IDs -->
that I wanted to use disk names instead of IDs, in case I replaced the drive
later on.

That still seems like a nice idea, but since every example I've seen online and
all the official documentation for `disko` uses ids rather than names, maybe I
should too.

So what's the ID? Dunno, but we can work it out with the POWER OF LS!

```bash
ls -l /dev/disk/by-id | grep nvme0n1$
```

Or, list everything (do it the long way) in the `/dev/disk/by-id` directory, and
only show me the lines that _end_ (that's the `$`) with the string `nvme0n1`
(that's the friendly name for an nvme drive).

If you're using a sata drive, it'd be `sda$` or `sdb$` or something. But
seriously, consider an upgrade my friend.

I got the snappy `nvme-Samsung_SSD_980_PRO_500GB_S5NYNL0T600787F`. There's also
another one with the same name apart from a `_1` added on the end. No idea what
that is for.

Add it to the configuration, along with the information that it is, in fact, a
disk.

<!-- TODO Link to commit 53135cc -->

We want to use a GPT partition table rather than an MBR (remember those? Max 4
primary partitions...)

<!-- TODO Link to commit ea88793 -->

We're finally ready to add our first partition, the boot partition.

<!-- TODO Link to commit 89aa14d -->

That's bigger than most of my commits so far, but hopefully it's pretty
self-explanatory. I want a 1GB disk called `efi` that will have a fat32 (`vfat`)
filesystem on it. Tell the partition table (gpt) that it's an EFI system
partition (`EF00`). Mount it at `/boot` with the default options, but only let
root touch the files (`umask=0077`).

Time to create the LVM pool:

<!-- TODO Link to commit 172ae15 -->

That's the physical volume taken care of. It's also the end of the configuration
for `disk`, that thing we declared way back on line 4. The volume group is
a separate device in the disko config, so be careful where you put it. It should
be outside the `disk` brackets.

In fact, I'm so stressed about you getting this right, I'm going to make it a
separate commit.

<!-- TODO Link to commit 549ea88 -->

<!-- TODO Insert gif of "Everybody got that?" from SpaceBalls -->

Time to add the volume group a name. It's pretty straight-forward:

<!-- TODO Link to commit e3c96c4 -->

Now here's the real stuff. The logical volumes. I'll do them one at a time
because commit messages are free.

Swap volume first:

<!-- TODO Link to commit 13e0442 -->

Root volume next. I made it 150GB before, but that number stings my eyes so I'm
going to change it to 160GB, which looks much nicer in binary and hex.

<!-- TODO Link to commit 63d4490 -->

And finally the home volume, which is going to take up the remaining space.

<!-- TODO Link to commit d763189 -->

Now it's time to include the new disko config in our configuration:

<!-- TODO Link to commit e99e29d -->

And delete the old mounting config from `hardware-configuration.nix`

<!-- TODO Link to commit 84e8d79 -->

Now the moment of truth - applying the new configuration.

```bash
sudo nixos-rebuild switch --flake .
```

```
building the ssytem configuration...
activating the configuration...
setting up /etc...
reloading user units for stooj...
restarting sysinit-reactivation.target
reloading the following units: -.mount
restarting the following units: boot.mount
```

It's taking a while to restart `boot.mount`. Things look grave.

Yep. Smeg.

```
A dependency job for boot.mount failed. See 'Journalctl -xe' for details
```

```
You are in emergency mode. After logging in, type "journalctl -xb" to view
system logs, "systemctl reboot" to reboot, or "exit"
to continue bootup.
Give root password for maintenance
(or press Control-D to continue):
```

I restarted the laptop, and it's

```
A start job is running for /dev/disk/by-partlabel/disk-nvme-efi
```

<!-- TODO Add panic gif -->

Oh no! I've bricked my laptop!

But wait. Here is where the true magic of NixOS emerges. Restart the machine and
watch for the bootloader to show. See that list of boot entries?

Those represent the different configurations you have applied. Use the arrow
keys to scroll back to the previous configuration, press ENTER, and _boom_. The
machine is booting and fixed again.

<!-- TODO I am invincible gif -->

OK, so the problem is something to do with mounting disks, and that probably
means there's a change in `/etc/fstab` between one generation and the next.

There is **undoubtedly** a better way to check this, but we only have a couple
of generations so far so it's easy enough to check each one.

## Time for a wee aside

If you've been relying on this blog alone so far for your information on how
Nix/NixOS works, then you have no idea how it works.

I'll try and fix a tiny bit of that understanding.

Nix (and NixOS) don't store packages and files in the normal place. Run `which
bash` on a normal Linux distro and you'll get `/usr/bin/bash` as the response.

Try that on a NixOS installation and you'll get something weird:
`/run/current-system/sw/bin/bash`. If you're using Home Manager (more on that
later), you'll get something even more different.

Take a closer look at that path:

```bash
ls -l /run/current-system/sw/bin/bash
```

```
lrwxrwxrwx 5 root root 76 Jan  1  1970 /run/current-system/sw/bin/bash -> /nix/store/qqz0gj9iaidabp7g34r2fb9mds6ahk8i-bash-interactive-5.2p32/bin/bash
```

Woah. It's a symlink to a path with a hash in it. So if I wanted to change my
system bash installation, I could update that symlink to point to a different
bash with a different hash in the path.

Each file/package/library managed by Nix/NixOS is stored in `/nix/store` in a
unique directory. The directory name is calculated using the hash of the
contents of the directory, so a different version of bash would have a different
hash.

So when you run a `nixos-rebuild switch`, it downloads/builds/creates these
directories in the `/nix/store`, and then updates the symlinks to point to the
new directory.
If you roll back, all the system needs to do is use the previous symlinks.

---

So, `/etc/fstab` is broken in the new configuration version.

Let's have a look at all the different versions of `/etc/fstab` we have, we'll
follow the chain of symlinks until we get to the store:

```bash
ls -l /etc/fstab
```

```
lrwxrwxrwx 1 root root 17 Oct 10:21 /etc/fstab -> /etc/static/fstab
```

OK, try that one:

```bash
ls -l /etc/static/fstab
```

```
lrwxrwxrwx 1 root root 53 Jan  1  1970 /etc/static/fstab -> /nix/store/fg2vipjjqva7mf76ncqxbfr44r1dsqhg-etc-fstab
```

Huh. Weird date: 0.

So we've definitely confirmed that the actual `fstab` file is stored in the nix
store. Let's have a look at _all_ of our fstabs for all our generations:

```bash
cat /nix/store/*-etc-fstab | grep boot
```

```
/dev/disk/by-partlabel/disk-nvme-efi /boot vfat defaults,umask=0077 0 2
/dev/disk/by-partlabel/efi /boot vfat fmask=0022,dmask=0022 0 2
/dev/disk/by-partlabel/efi /boot vfat fmask=0022,dmask=0022 0 2
```

That top result has got to be the offending one 🤔. Why is the name of the disk
wrong...? I guess `disko` expects drives to be named a particular thing, and
we've not matched their naming scheme. Remember the nesting of our disks.nix
data is:

```
disko -> devices -> disk -> nvme -> content -> partitions -> efi
```

which looks suspiciously similar to the path that disko is detecting. How can we
set this so it'll continue to work if we reinstall, but will work now?

Oooh, looking at the [source code](https://github.com/nix-community/disko/blob/d7d57edb72e54891fa67a6f058a46b2bb405663b/lib/types/gpt.nix#L70)
there is a `label` option, and the default is
`"${config._parent.type}-${config._parent.name}-${partition.config.name}"`. That
looks suspiciously like what disko is expecting of our disk.

<!-- TODO Link to commit 74f0a55 -->

While we're here, we should fix something _else_ that's wrong. The `efi`
partition that I made manually started at `1MB`, not at the very start of the
disk. I can't for the life of me remember why I do this, but I've done it for a
very long time so now it's become doctrine.

Anyway, we should match that in the disko config.

<!-- TODO Link to commit 9886d8b -->

The other thing that is loopy about my configuration is that I **changed the
size of the logical volumes!!**. I don't _think_ disko will try to adjust the
existing volumes to suit, and it shouldn't affect how they are mounted, so it's
a safe change.

It _does_ mean that the code is a lie though.

Let's see if that fixes things:

```bash
sudo nixos-rebuild switch --flake .
```

```
building the system configuration...
activating the configuration...
setting up /etc...
reloading user units for stooj...
restarting sysinit-reactivation.target
reloading the following units: -.mount, boot.mount
the following new units were started: sysinit-reactivation.target, systemd-tmpfiles-resetup.service
```

<!-- TODO Gif of Bingo saying Ooos -->

Our partitioning scheme is _reproducable_. We can reinstall NixOS on this
machine and it will have the correct partitions without us manually partitioning
things like it's 1995.

# References

- [disko/docs/HowTo.md - Installing NixOS module · nix-community/disko](https://github.com/nix-community/disko/blob/master/docs/HowTo.md#installing-nixos-module)
- [umask - ArchWiki](https://wiki.archlinux.org/title/Umask)
- [GPT fdisk - ArchWiki](https://wiki.archlinux.org/title/GPT_fdisk)
- [FAT - ArchWiki](https://wiki.archlinux.org/title/FAT)
- [LVM - ArchWiki](https://wiki.archlinux.org/title/LVM)
- [disko/lib/types/gpt.nix](https://github.com/nix-community/disko/blob/d7d57edb72e54891fa67a6f058a46b2bb405663b/lib/types/gpt.nix#L70)
