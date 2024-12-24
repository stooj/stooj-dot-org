Title: New Installation
Date: 2024-09-18T15:14:34
Category: NixOS

![console installation screen for NixOS](images/new-installation/first-installation-screen.png)

I'm staring at the install screen for [NixOS](https://nixos.org/download/). It's Linux, but unlike any other Linux distribution out there[^1]. And I'm going to completely rebuild every piece of tech I can using it, starting today.

Caveats:

1. I'm planning to migrate as much as possible across to NixOS, but I already have access to some things and I'm going to visit them later on. Things like... an internet connection, and a local network with wireless.
2. And a working computer to type these notes.
3. And use that existing computer to set up the git repo.

To begin with, I'm going to have to make heavy use of my currently working computer to do things like writing these notes and probably writing some of the configuration, so I'd better document which machine is which.

I've got two laptops here:

1. `proteus`, the laptop that I'm installing NixOS on.
2. `drummer`, the laptop that I'm documenting things on.

`proteus` will be the first step of my NixOS-ing everything journey. The idea will be to have everything as stateless as possible, and reconfigurable/reinstallable with minimal effort.

`drummer` will be assimilated into my NixOS configuration later, once I've gotten `proteus` running nicely and configured nicely and we have secrets management and nothing imperative in our config.

I'm installing using the minimal ISO image for NixOS v24.05. I'm also going to be using the [Installation Guide in the NixOS Manual](https://nixos.org/manual/nixos/stable/#ch-installation) as my guide on how to do all this stuff.

## Phase 0: An interlude where I create a new Git repo to store all the stuff

Before I do **anything** else, I need a place to store all my configs. For now, I'm going to store it in [GitHub](https://github.com) but depending on requirements I might migrate to [GitLab](https://gitlab.com) or something else in the future.

I'm going to use my existing machine to set up the git repo.

1. Create the directory

   ```bash
   # On drummer
   mkdir nix-config
   cd nix-config
   ```

2. Add a `README.md` file (mainly so we have a `main` branch to base from).

   ```bash
   # Still on drummer
   echo "# Stoo's NixOS configurations" >> README.md
   git add README.md
   git commit --message "Initial commit"
   ```

   <!-- TODO Link to commit 010cb0e -->

3. Create a branch for this post.
   ```bash
   # Haven't stopped being on drummer
   git checkout -b new-installation
   ```

Now I have a place to store all the code.

## Hardware

The first piece of tech to get the NixOS treatment is my partner's Entroware Proteus laptop. I'm sure she won't mind lending it for a while.

You might notice that I'm doing this installation in a VM, not a physical machine. That's for the screenshots. Well done for being clever and spotting it.

## Phase 1: In which we write the OS to the harddrive.

So far, this looks very similar to installing Arch, including a way of opening the manual in [w3m](https://w3m.sourceforge.net/).

![nixos manual in a terminal window](images/new-installation/nixos-manual-in-terminal.png)

~Networking is first~. Running everything as root is first. I hate it already, but I suppose it's less wear-and-tear on my `s`, `u`, `d`, and `o` keyboard keys.

```bash
# NOW we're on proteus
sudo --login
```

![terminal window with root user logged in](images/new-installation/now-i-am-root.png)

Now I am root.

There's going to be some imperative setup involved in getting this stuff set up for the first time. I'm going to try and keep a track of everything that I do imperatively so I can declare it in my configuration later on.

### Network

Like my wireless network. Here's how to connect to my wireless manually (don't hack me):

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

   set_network 0 ssid "sailinghigara"
   OK

   set_network 0 psk "ThisIsMywirelessPasswordNotReallyThough"
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
                     # if it doesn't it's always DNS to blame.

   ```

If for some reason you are reading this and you are not me and you've followed these instructions exactly and are in the same building as I am then you are now connected to my wireless. If you are somewhere else, you might need to adjust the SSID and PSK in the above commands.

Imperative thing number 1.

### Partitioning

Lets pretend that I _don't_ know that this laptop uses UEFI. How can I tell if the laptop uses UEFI or BIOS?

An easy way is to ask the Linux kernel, it will have populated some files in `/sys/firmware/efi` with values. For example:

```bash
cat /sys/firmware/efi/fw_platform_size
```

Ooh, I have 64 of those! If there isn't a `/sys/firmware/efi` directory, then it's a safe bet that the system uses BIOS and I'd need to read the [Legacy Boot (MBR)](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-MBR) instructions, and it might be time to consider buying a new machine. Or step up and use a real machine instead of a VM.

I've formatted disks many many times at this point and I'm going to use [sgdisk](https://man.archlinux.org/man/sgdisk.8) to do it. The easier options are [gdisk](https://man.archlinux.org/man/gdisk.8) or [parted](https://man.archlinux.org/man/parted.8) for a less scary experience. The idea is to (for now) is to have a small fat32 partition for EFI, and the rest of the drive taken up by an LVM. I'll then split the LVM into three:

- root
- swap
- home

Other thing to note here is that I am **not** setting up disk encryption yet. I plan to do that soon, but I want to declare that in my NixOS code, not set it up manually like some kind of animal.

Back to partitioning!

1. Figure out what the drive is called:

   ```
   [root@nixos:~]# lsblk

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

   I'm about to wipe an [Arch Linux](https://archlinux.org/) installation, so what's plugged into this machine?

   - I've got a 57.3G disk on `/dev/sda`, that's the USB stick that has the NixOS liveUSB on it.
   - There's a 465.8G disk on `/dev/nvme0n1`. That's the nvme disk inside the laptop, and it's the one I want to install NixOS onto.

2. Wipe the existing partitions completely. This runs a slight risk of running out of room on the motherboard's NVRAM, but that's [fixable if it happens](https://askubuntu.com/a/893434).

   ```bash
   sgdisk --zap-all /dev/nvme0n1   # Note that I'm using the 465.8G disk I picked above
   ```

3. Create new partitions, a wee[^2] UEFI one, and all the rest should go to a single data partition for the logical volumes.
   
   ```bash
   sgdisk --new=0:1M:1G /dev/nvme0n1
   sgdisk --new=0:0:0 /dev/nvme0n1
   ```
   
4. Set their typecode. Don't know what the typecode is for? Neither do a lot of people, but the `gdisk` explains it: [Using the GPT Linux Filesystem Data Type Code](http://www.rodsbooks.com/linux-fs-code/index.html).
   
   ```bash
   sgdisk --typecode=1:EF00 /dev/nvme0n1
   sgdisk --typecode=2:8e00 /dev/nvme0n1
   ```
   
5. Give the partitions sensible labels
   
   ```bash
   sgdisk --change-name=1:efi /dev/nvme0n1
   sgdisk --change-name=2:sys /dev/nvme0n1
   ```
   
6. There's an old LVM on this drive already, so I need to wipe it out. Note to self: if there isn't an old LVM here you don't need to wipe the old LVM.
   
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

7. Make the LVM physical volume on the shiny new second partition on `/dev/nvme0n1`:
   
   ```bash
   pvcreate /dev/nvme0n1p2
   ```
   
8. Create a volume group with an arbitrary name on the same partition:
   
   ```bash
   vgcreate ginstoo /dev/nvme0n1p2
   ```
   
9. Create the logical volumes on the volume group.
   
   [!TIP]
   NixOS is **way** hungrier for disk space than traditional Linux OSes are, so I'm giving it millions of space.
   
   ```bash
   lvcreate --size 16G ginstoo --name swap
   lvcreate --size 150G ginstoo --name root
   lvcreate --extents 100%FREE ginstoo --name home
   ```
   
10. Format the efi partition as Fat32:
   
   ```bash
   mkfs.fat -F32 -n boot /dev/nvme0n1p1
   ```
   
11. Format the logical volumes as ext4, because it's the easiest filesystem to start with. Maybe we'll change it at some future date, but I cannot be bothered messing about with ZFS just now:
    
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

### Generate the NixOS configuration

I need a configuration file that will describe the expected configuration of this laptop.

```bash
nixos-generate-config --root /mnt
```

This will create a couple of files in `/mnt/etc/nixos/`:

- `/mnt/etc/nixos/configuration.nix` - the configuration for software, services, boot etc.
- `/mnt/etc/nixos/hardware-configuration.nix` - any detected physical hardware configuration (like the partition scheme I just made).

<!-- TODO Link to commit 4f3cd2d -->

### Modify the generated configuration files

There isn't a lot to change with these files so far; it's declared `systemd-boot` as the bootloader, and the partitions on the disk. The laptop won't _do_ much if I install it as-is, but it'll work I think.

Let's tweak `configuration.nix` just a tiny bit though. I need a hostname.

<!-- TODO Link to commit fc193c8 -->

I also need to choose the networking stack. This laptop is going to be a workstation with a desktop environment or something, so I'm going to choose NetworkManager to handle networking.

<!-- TODO Link to commit 92301b1 -->

I like everything to be in UTC, but I live on planet Earth, and the rest of the population seem to inexplicably like timezones.

Every timezone is listed in `/etc/zoneinfo` somewhere, so I've dug around in there and found something appropriate. Maybe I should just use [EVE Standard Time](https://universe.eveonline.com/lore/universal-time) instead. I mean UTC 😊.

<!-- TODO Link to commit 2aa066f -->

That should be it for `configuration.nix`. Time to have a look at `hardware-configuration.nix`.

Straight away, it's clear that `nixos-generate-config` has hard-coded UUIDs for the disk partitions. Cool, but that hard-codes this configuration to this specific harddisk, and I'll have to modify it if I want to swap the disk out for something bigger. Changing this may or may not be a good idea.

<!-- TODO Link to commit 2791279 -->

That _should_ be it. Now to run the installation:

```bash
nixos-install
```

The installer asked me for a root password. This is the other thing that I want declared as part of my code by using some kind of secrets manager or something once I figure out how to manage secrets. For now I've set it manually.

Reboot the machine:

```bash
reboot
```

Hurrah! I have an installed OS!

```
<<< Welcome to NixOS 24.05.2997.086b448a5d54 (x86_64) - tty1 >>>

Run 'nixos-help' for the NixOS manual.

proteus login: root
Password:

[root@proteus:~]# _
```

Need to connect to the network again. This time I'm going to imperatively do it using NetworkManager rather than wpa_supplicant.

```bash
nmcli device wifi connect "sailinghigara" \
    password "ThisIsMywirelessPasswordNotReallyThough" \
    name "sailinghigara"
```

Again, this needs to be modified unless connecting to exactly the same network.

## Phase 2: Where I install some essential tools and users

This laptop will have two users:

- stooj
- pindy

Create those two users and add them to the `networkmanager` group (so they can [manage network settings](https://nixos.org/manual/nixos/stable/#sec-networkmanager)).

<!-- TODO Link to commit 29a44e3 -->

Ugh. The passwords are going to have to be set manually just now, because I don't have a way to manage secrets yet. I'll get to it, promise.

Time to give my user access to `sudo` so I don't have to touch the `root` user again:

<!-- TODO Link to commit 0755904 -->

Next essential change for me: changing the editor. Nano is more powerful than you think (TODO Write that blog post) but it's no [vim](https://www.vim.org/).

From here onwards, all changes will be made with vim. Until I switch to neovim.

<!-- TODO Link to commit ee1787b -->

I've still got my existing computer for writing this post, and it's going to be future changes easier if I enable SSH and do things remotely.

Ugh, will it though? If I'm doing it remotely, then the system is already 90% there; I don't need much else to make this a working machine. But if I'm forced to use it directly, I'm going to want things like sound, and a web browser, and anything else the kids like these days.

**Decisions**

Nope, SSH for now. I'm going to use it anyway, so may as well make today as frictionless as I can. Enabling OpenSSH and adding my public key.

<!-- TODO Link to commit b9ce164 -->

<!-- TODO Crickets gif or something -->

Nothing happened. That's because the configuration is declarative; I'm declaring what I _want_ the system to look like, but I now need to run `nixos-rebuild` to get the system to apply the changes.

The desire:

> Set course for Pollux V, warp factor 6

The apply:

> Engage.

<!-- TODO Patrick Stewart Engage gif -->

To apply the changes, there's a command with a few different options you can pass it.

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

I have normal users too.

```bash
grep --extended-regexp "(stooj|pindy)" /etc/passwd
```

Those users need imperative passwords 🙁. I _will_ fix this, I promise. For now, set them manually.

```bash
passwd stooj
passwd pindy
```

I can even SSH in from `drummer`:

```bash
ssh stooj@192.168.1.147
```

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:gHECuL9oQNI+W4zUZISxYxatkNppIyRAefhIlG1pWeE.
Please contact your system administrator.
Add correct host key in /home/stooj/.ssh/known_hosts to get rid of this message.
Offending RSA key in /home/stooj/.ssh/known_hosts:55
Host key for 192.168.1.147 has changed and you have requested strict checking.
Host key verification failed.
```

Whoops, just got to delete a couple of lines from my `~/.ssh/known_hosts` file...

```
The authenticity of host '192.168.1.147 (192.168.1.147)' can't be established.
ED25519 key fingerprint is SHA256:gHECuL9oQNI+W4zUZISxYxatkNppIyRAefhIlG1pWeE.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.1.147' (ED25519) to the list of known hosts.

[stooj@proteus:~]$
```

Nice.

What other things do we need to manage/set up?

- Switch to flakes
- User configuration files
- Secrets
- More system packages

[^1]:
    There might be a bunch of NixOS clones I don't know about. But apart from them.

[^2]: Scots for "little": [Dictionaries of the Scots Language:: SND :: wee n1 adj adv](https://dsl.ac.uk/entry/snd/wee_n1_adj_adv)

# References

- [Installation Guide - NixOS Manual](https://nixos.org/manual/nixos/stable/#ch-installation)
- [w3m manual](https://w3m.sourceforge.net/MANUAL)
- [Unified Extensible Firmware Interface - ArchWiki](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface)
- [LVM - ArchWiki](https://wiki.archlinux.org/title/LVM)
- [GPT fdisk - ArchWiki](https://wiki.archlinux.org/title/GPT_fdisk)
- [Networking - Appendix A. Configuration Options - NixOS Manual](https://nixos.org/manual/nixos/stable/options#opt-networking.hostName)
- [User Management - NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-user-management)
