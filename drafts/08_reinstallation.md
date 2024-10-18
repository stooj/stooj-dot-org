Title: Reinstallation to test disk partitioning
Date: 2024-10-17T20:27:16
Category: NixOS

So we've got a configuration for our disks. It sorta works, but the
configuration doesn't actually match reality, and it doesn't seem like we've
_gained_ any utility?

Let's see an amazing thing. Boot into the LiveUSB again like we did in the
installation

<!-- TODO Add link to installation 2 step -->

Connect to the wireless network (this'd be a lot faster if I had an ethernet cable):

1. Turn on the `wpa_supplicant` service:

   ```bash
   sudo --login
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

   Then run this:

Uh, wait. Spoiler alert. This is going to wipe the hard drive for the laptop
again. If you've been following along, there's nothing important on it. If you
have things you want to keep, now is time to start implementing your backup
strategy.

```bash
sudo nix run \
    --extra-experimental-features 'nix-command flakes' \
    'github:nix-community/disko/latest#disko-install' \
    -- \
    --write-efi-boot-entries \
    --flake 'github:stooj/nix-config#drummer' \
    --disk nvme /dev/nvme0n1
```

You need to provide the name of the disk configuration and the name of the hard
disk you want to target (in this case `nvme` and `/dev/nvme0n1`)

And change the address of the `--flake` argument to be your repo and hostname.

It'll do some stuff. Amazing stuff. One thing it **won't** do is ask for a root
password.

So we'll set one. Disko unmounts everything, so we need to remount it first:

```bash
    mount /dev/ginstoo/root /mnt
    mount --mkdir /dev/ginstoo/home /mnt/home
    mount --mkdir /dev/disk/by-partlabel/efi /mnt/boot
```

Then set the password

```bash
nixos-enter --root /mnt --command 'passwd root'
nixos-enter --root /mnt --command 'passwd stooj'
```

Now reboot the machine and boot from the hard disk again.

<!-- TODO Gif of fireworks or something -->

I can log in as `stooj`! I can open `vim`! Aaaand, if I run `lvdisplay`, I can
see that the `root` partition 160GB.

<!-- TODO What the hell happened gif -->

That single `nix run disko-install` command downloaded our configuration
straight from GitHub, reformatted the `/dev/nvme0n1` disk, set up the
partitions, installed nixos and applied our existing configuration. I recreated
my entire operating system with a single command.

OK, the configuration is still a bit anaemic, but even if it were huge it'd
still work the same way.

And once we get secrets so we can configure passwords declaratively, we won't
need to run those two `nixos-enter` commands.

And once we get a network cable, we won't need to configure the wireless!

If something happens to this machine, it'll be _trivial_ to reinstall the OS.

Meanwhile, back on `proteus`, it's going to complain the next time you try to
SSH into `drummer`. That's because the system SSH keys have been regenerated, so
you'll need to delete the appropriate lines in `~/.ssh/known_hosts`.
