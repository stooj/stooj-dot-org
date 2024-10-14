Title: New Installation again
Date: 2024-10-05T17:58:19
Category: NixOS

![console installation screen for NixOS](images/new-installation/first-installation-screen.png)

I'm staring at the install screen for [NixOS](https://nixos.org/download/). It's
eerily familiar, like I've been in this exact place before.

I'm going to completely rebuild every piece of tech I can using NixOS, starting
**today**.

Caveats:

1. I'm planning to migrate as much as possible across to NixOS, but I already
   have access to some things and I'm going to visit them later on. Things
   like... an internet connection, and a local network with wireless.
2. And a working computer to type these notes.
3. And use that existing computer to set up the git repo.

I'm going to end up talking about my existing computer more than I'd like, so
I'll tell you it's name so I can use that name and you'll know what I'm talking
about.

I've got two laptops here:

1. `drummer`, the laptop that we're installing NixOS on.
2. `proteus`, the laptop that I'm documenting things on.

`drummer` will be the first step of my NixOS-ing everything journey. The idea
will be to have everything as stateless as possible, and
reconfigurable/reinstallable with minimal effort.

`proteus` will be assimilated into my NixOS configuration later, once I've
gotten `drummer` running nicely and configured nicely and we have secrets
management and nothing imperative in our config.

## Hardware

The first piece of tech to get the NixOS treatment is my [System76 Darter Pro 8](https://tech-docs.system76.com/models/darp8/README.html).
I could use `proteus`, but my partner uses that for all sorts of things.

## Phase 0: In which we find a bunch of stuff already in the repo

Turns out there's some junk already in this nixos-config repo. Let's chuck all
that out to begin with, we don't need it.

<!-- TODO Link to commit ac3a78d -->

## Phase 1: In which we write the OS to the harddrive.

Turns out you can read the manual during the installation with [w3m](https://w3m.sourceforge.net/). Could be
handy.

![nixos manual in a terminal window](images/new-installation/nixos-manual-in-terminal.png).

~Networking is first~. Running everything as root is first. I hate it already,
but it's what the kids like these days, innit?

```bash
sudo --login
```

![terminal window with root user logged in](images/new-installation/now-i-am-root.png)

Now I am root.

There's going to be some imperative setup involved in getting this stuff set up
for the first time. I'm going to try and keep a track of everything that I do
imperatively so I can declare it in my configuration later on.

### Network

We don't have a wired network where we're staying, so wireless is our only
option. Back in the old days of Linux, this would have been **A PAIN**. And I
don't even think about it any more 🥳. How times have changed.

1. Turn on the `wpa_supplicant` service:

   ```bash
   systemctl start wpa_supplicant
   ```

2. Run `wpa_cli`

   ```bash
   wpa_cli
   ```

3. Configure the wireless connection in `wpa_cli`

   ```
   add_network
   0

   set_network 0 ssid "rentalflat"
   OK

   set_network 0 psk "DefinitelyTheWirelessPassword"
   OK

   set_network 0 key_mgmt WPA-PSK
   OK

   enable_network 0
   OK

   ### Wait for `CTRL-EVENT-CONNECTED` ###

   quit
   ```

4. Ping something to check it worked:

   ```bash
   ping 1.1.1.1
   ping archive.org  # Checking that DNS works. I don't know why it wouldn't but
                     # it's always DNS.

   ```

   Those few disconnected minutes were very peaceful, but we're reconnected to the
   internet. What did I miss?

Oh, that's imperative thing number 1 for anyone keeping track. Actually, never
mind. I don't plan on using `wpa_supplicant` for this, so we can forget about it
once we've installed the OS.

### Partitioning

The Darter Pro uses [coreboot](https://www.coreboot.org/) ❤️ so we'll be using UEFI rather than a BIOS. If you
aren't lucky enough to be running Fast, secure and flexible Open Source firmware
then you can ask the Linux kernel if it's detected EFI:

```bash
# If this returns a number, then you've got efi.
cat /sys/firmware/efi/fw_platform_size
```

If you're using BIOS, check out the [Legacy Boot (MBR)](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-MBR) instructions.

I'm going to use `sgdisk` to format my disks. It won't help guide you, but it's
easy to document the steps and script them as well.

I'm planning on encrypting the disk once the nix config is a bit more fleshed
out and I can declare the full-disk encryption as part of my configuration.

For now, I'll have a small (but not too small, I've run out of room in the past
with the recommended defaults) fat32 partition for EFI, and the rest of the
drive as an [LVM](https://wiki.archlinux.org/title/LVM).

> Why bother with an LVM?

Why do we do any of the things we do? Actually, I have run out of room on my
root partition in the past, and it was pretty cool to just shrink the home and
expand the root into the reclaimed space, rather than reinstalling. Try doing
that on another OS.

So the LVM will be split into three logical volumes:

- root
- swap
- home

Yes, I have a swap partition. Direct all complaints to the comments section.

1. Figure out what the drive is called:

   ```
   [root@nixos:~]# lsblk

   NAME             MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
   NAME             MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
   loop0              7:0    0     1G  1 loop /nix/.ro-store
   sda                8:0    1  57.3G  0 disk
   ├─sda1             8:1    1   1.1G  0 part /iso
   └─sda2             8:2    1     3M  0 part
   nvme0n1          259:0    0 465.8G  0 disk
   ├─nvme0n1p1      259:1    0  1023M  0 part
   └─nvme0n1p2      259:2    0 464.8G  0 part
     ├─ginstoo-swap 254:0    0    16G  0 lvm
     ├─ginstoo-root 254:1    0   128G  0 lvm
     └─ginstoo-home 254:2    0 320.8G  0 lvm
   ```

   We're about to wipe an [Arch Linux](https://archlinux.org/) installation, so
   what's plugged into this machine?

   - I've got a 57.3G disk on `/dev/sda`, that's the USB stick that has the
     NixOS liveUSB on it.
   - There's a 465.8G disk on `/dev/nvme0n1`. That's the nvme disk inside the
     laptop, and it's the one we want to install NixOS onto.
   - This is **so** familiar 😖

2. Wipe the existing partitions completely. This runs a slight risk of running
   out of room on the motherboard's NVRAM, but that's
   [fixable if it happens](https://askubuntu.com/a/893434).

   ```bash
   sgdisk --zap-all /dev/nvme0n1   # Note that I'm using the 465.8G disk I picked above
   ```

3. Create new partitions, a wee[^2] UEFI one, and all the rest should go to a
   single data partition for the logical volumes.
   ```bash
   sgdisk --new=0:1M:1G /dev/nvme0n1
   sgdisk --new=0:0:0 /dev/nvme0n1
   ```
4. Set their typecode. Don't know what the typecode is for? Neither do a lot of
   people, but the `gdisk` explains it: [Using the GPT Linux Filesystem Data Type Code](http://www.rodsbooks.com/linux-fs-code/index.html).
   ```bash
   sgdisk --typecode=1:EF00 /dev/nvme0n1
   sgdisk --typecode=2:8e00 /dev/nvme0n1
   ```
5. Give the partitions sensible labels
   ```bash
   sgdisk --change-name=1:efi /dev/nvme0n1
   sgdisk --change-name=2:sys /dev/nvme0n1
   ```
6. Remove the old LVM volume groups and physical groups (if you don't already
   have an old lvm set up, skip this step. Or reuse the existing PV and VG. Why
   are you following this tutorial step by step? You obviously know enough to
   make your own decisions.):

   ```bash
   vgremove ginstoo
   ```

   ```
   Do you really want to remove volume group "ginstoo" containing 3 logical volumes? [y/n]: y
   Do you really want to remove active logical volume ginstoo/swap? [y/n]: y
     Logical volume "swap" successfully removed.
   Do you really want to remove active logical volume ginstoo/root? [y/n]: y
     Logical volume "root" successfully removed.
   Do you really want to remove active logical volume ginstoo/home? [y/n]: y
     Logical volume "home" successfully removed.
     Volume group "ginstoo" successfully removed
   ```

   ```bash
   pvremove /dev/nvme0n1p2
   ```

   I probably didn't need to do this, I could have just reused the existing
   volumes. But that'd ruin the tutorial a bit.

7. Make the LVM physical volume on the shiny new second partition on
   `/dev/nvme0n1`:
   ```bash
   pvcreate /dev/nvme0n1p2
   ```
8. Create a volume group with an arbitrary name on the same partition:
   ```bash
   vgcreate ginstoo /dev/nvme0n1p2
   ```
9. Create the logical volumes on the volume group.
   [!TIP]
   NixOS is **way** hungrier for disk space than traditional Linux OSes are, so
   I'm giving it millions of space.
   ```bash
   lvcreate --size 16G ginstoo --name swap
   lvcreate --size 150G ginstoo --name root
   lvcreate --extents 100%FREE ginstoo --name home
   ```
10. Format the efi partition as Fat32:
    ```bash
    mkfs.fat -F32 -n boot /dev/nvme0n1p1
    ```
11. Format the logical volumes as ext4, because it's the easiest filesystem to
    start with. Maybe we'll change it at some future date, but I cannot be
    bothered messing about with ZFS just now:
    ```bash
    mkfs.ext4 -L nixos /dev/ginstoo/root
    mkfs.ext4 -L home /dev/ginstoo/home
    ```
12. Turn on the swap partition:
    ```bash
    mkswap --label swap /dev/ginstoo/swap
    swapon /dev/ginstoo/swap
    ```
13. Mount the filesystems:

    ```bash
    mount /dev/ginstoo/root /mnt
    mount --mkdir /dev/ginstoo/home /mnt/home
    mount --mkdir /dev/disk/by-partlabel/efi /mnt/boot
    ```

Whoops, all that work was by hand, which is not reproducable. Time to officially
start our TODO list.

#### Things to add to the configuration some day

- [ ] Disk partitioning and formatting

---

### Generate the NixOS configuration

We need a configuration file that will describe the expected configuration of
this laptop.

```bash
nixos-generate-config --root /mnt
```

This will create a couple of files in `/mnt/etc/nixos/`:

- `/mnt/etc/nixos/configuration.nix` - the configuration for software, services,
  boot etc.
- `/mnt/etc/nixos/hardware-configuration.nix` - any detected physical hardware
  configuration (like the partition scheme we just made).

<!-- TODO Link to commit 33f25f8 -->

### Modify the generated configuration files

There isn't a lot to change with these files so far; it's declared
`systemd-boot` as the bootloader, and the partitions on the disk. The laptop
won't _do_ much if we install it as-is, but it'll work I think.

Let's tweak `configuration.nix` just a tiny bit though. We need a hostname.

<!-- TODO Link to commit 429870c -->

We also need to choose the networking stack. This laptop is going to be a
workstation with a desktop environment or something, so I'm going to choose
NetworkManager to handle networking.

<!-- TODO Link to commit 825f0fc -->

We are in Spain at the moment, so set the timezone to `Europe/Madrid`. You can
find out the one you need at your house by poking around `/etc/zoneinfo` or by
running `timedatectl list-timezones`

<!-- TODO Check `timedatectl` works in the nixos live session -->

<!-- TODO Link to commit 1e21a98 -->

That should be it for `configuration.nix`. Let's have a look at
`hardware-configuration.nix` now.

The `nixos-generate-config` has added hard-coded UUIDS for the disk partitions
to the `hardware-configuration.nix`, which means our config won't be reusable if
we:

1. Get a new laptop
2. Call it the same thing

or

3. Buy a bigger hard disk.

<!-- TODO Link to commit dcb80bb -->

That _should_ be it. Time to run the installation:

```bash
nixos-install
```

The installer will ask you for a root password. This is the other thing that I
want declared as part of my code, but using some kind of secrets manager or
something. Once I figure out how to manage secrets.

#### Things to add to the configuration some day

- [ ] Disk partitioning and formatting
- [ ] Root user password

---

Reboot the machine:

```bash
reboot
```

Hurrah! We have an installed OS!

```
<<< Welcome to NixOS 24.05.2997.086b448a5d54 (x86_64) - tty1 >>>

Run 'nixos-help' for the NixOS manual.

proteus login: root
Password:

[root@proteus:~]# _
```

Need to connect to the network again. This time we're going to imperatively do
it using NetworkManager rather than wpa_supplicant.

```bash
nmcli device wifi connect "rentalflat" \
    password "DefinitelyTheWirelessPassword" \
    name "rentalflat"
```

Again, you'll need to modify this command to suit your own network.

#### Things to add to the configuration some day

- [ ] Disk partitioning and formatting
- [ ] Root user password
- [ ] Wireless network connection details for `rentalflat`

## Phase 2: Where we install some essential tools and users

This laptop will have two users:

- stooj
- pindy

Create those two users and add them to the `networkmanager` group (so they can
[manage network settings](https://nixos.org/manual/nixos/stable/#sec-networkmanager)).

<!-- TODO Link to commit 7bb0a75 -->

Ugh. The passwords are going to have to be set manually just now, because I
don't have a way to manage secrets yet. I'll get to it, promise.

Time to give my user access to `sudo` so I don't have to touch the `root` user
again:

<!-- TODO Link to commit f953682 -->

Next essential change for me: changing the editor. Nano is more powerful than
you think (TODO Write that blog post) but it's no [vim](https://www.vim.org/).

From here onwards, all changes will be made with vim. Until I switch to neovim.

<!-- TODO Link to commit 437fd7d -->

I've still got my existing computer for writing this post, and it's going to be
future changes easier if I enable SSH and do things remotely.

Ugh, will it though? If I'm doing it remotely, then the system is already 90%
there; I don't need much else to make this a working machine. But if I'm forced
to use it directly, I'm going to want things like sound, and a web browser, and
anything else the kids like these days.

**Decisions**

Nope, SSH for now. I'm going to use it anyway, so may as well make today as
frictionless as I can. Enabling OpenSSH and adding my public key.

<!-- TODO Link to commit d5f68ff -->

<!-- TODO Crickets gif or something -->

Nothing happened. That's because the configuration is declarative; we're
declaring what we _want_ the system to look like, but we now need to run
`nixos-rebuild` to get the system to apply the changes.

The desire:

> Set course for Pollux V, warp factor 6

The apply:

> Engage.

<!-- TODO Patrick Stewart Engage gif -->

To apply the changes, there's a command with a few different options you can
pass it.

```bash
nixos-rebuild switch
# Which builds and activates the new configuration in your current session.
# It's kinda amazing.

# Or
nixos-rebuild boot
# Build and set the bootloader to boot into the new configuration on the next
# reboot

# There's also
nixos-rebuild test
# Which doesn't do what I thought it did. It switches the running system, but if
# doesn't touch the bootloader so things will revert to the previous version
# when you reboot.
```

So, time to apply the changes!

```bash
nixos-rebuild switch
```

Woah.

`sshd` is now running.

```bash
systemctl status sshd.service
```

`vim` is installed

```bash
vim --version
```

We have normal users too.

```bash
grep --extended-regexp "(stooj|pindy)" /etc/passwd
```

Those users need imperative passwords 🙁. This'll get fixed in the future, but
better set some passwords manually for now.

```bash
passwd stooj
passwd pindy
```

I can even SSH in from proteus:

```bash
ssh stooj@192.168.1.147
```

<!-- TODO Update the IP address and fingerprint -->

```
The authenticity of host '192.168.1.147 (192.168.1.147)' can't be established.
ED25519 key fingerprint is SHA256:gHECuL9oQNI+W4zUZISxYxatkNppIyRAefhIlG1pWeE.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.1.147' (ED25519) to the list of known hosts.

[stooj@drummer:~]$
```

Nice.

#### Things to add to the configuration some day

- [ ] Disk partitioning and formatting
- [ ] Root user password
- [ ] Wireless network connection details for `rentalflat`
- [ ] Passwords for `pindy` and `stooj`
- [ ] SSH known hosts file maybe? It'd be read-only, which would suck. I'll think
   about it.

What other things do we need to manage/set up?

- [ ] Switch to flakes
- [ ] User configuration files
- [ ] Secrets
- [ ] More system packages

[^1]:
    There might be a bunch of NixOS clones I don't know about. But apart from
    them.

[^2]: Scots for "little": [Dictionaries of the Scots Language:: SND :: wee n1 adj adv](https://dsl.ac.uk/entry/snd/wee_n1_adj_adv)

# References

- [Installation Guide - NixOS Manual](https://nixos.org/manual/nixos/stable/#ch-installation)
- [w3m manual](https://w3m.sourceforge.net/MANUAL)
- [Unified Extensible Firmware Interface - ArchWiki](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface)
- [LVM - ArchWiki](https://wiki.archlinux.org/title/LVM)
- [GPT fdisk - ArchWiki](https://wiki.archlinux.org/title/GPT_fdisk)
- [Networking - Appendix A. Configuration Options - NixOS Manual](https://nixos.org/manual/nixos/stable/options#opt-networking.hostName)
- [User Management - NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-user-management)
