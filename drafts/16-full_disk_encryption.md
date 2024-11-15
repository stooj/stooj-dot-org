Title: (Almost) Full Disk Encryption
Date: 2024-11-15T14:09:39
Category: NixOS

I've ticked off _everything_ that I manually configured; I now have a fully-nix-managed laptop. But it's not quite ready for the road, not least because it doesn't have a web browser. But it also doesn't have full-disk encryption, and that's an essential part of having a machine that might get left in a coffee shop one day.

Like in <!-- TODO Add link -->"Disk Configuration", changes to the partition layout won't be applied until a reinstall, but I'm ready to reinstall now. It'll be a good test to check that everything is correctly managed in code and I haven't forgotten anything.

First off, make a new branch. I need to go back through my older drafts and add the branching commands in there too.

```bash
cd ~/code/nix/nix-config
git checkout -b full-disk-encryption
```

There is one wrinkle here; storing the disk encryption keys as code. The thing is I can't, at least not using the current installation method I'm using. See [this comment in nix-community/disko#641](https://github.com/nix-community/disko/issues/641#issuecomment-2136553547) for an explanation. I'll take a note of `nixos-anywhere` though, that sounds interesting.

So the installer will _ask_ me for a disk encryption passphrase during the installation. I think that's acceptable, because I'm already doing a little manual work at installation time (booting the installer, connecting to the wireless, running the install command).

The boot partition is going to remain unencrypted because it needs to be unencrypted to boot.

Because `disko` is amazing, there's not a lot to change in our configuration. I just need to take the existing `sys.content` and wrap it inside a `luks` type.

<!-- TODO Link to commit c210928 -->

As a smoke test, apply the config (it won't touch the disk partitioning of course)

```bash
sudo nixos-rebuild switch --flake .
```

OK. Push the changes to GitHub:

```bash
git push --all
```

Time to reboot into the LiveUSB again and connect to the wireless network.

<!-- TODO Add link to installation 2 step -->

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

Nuke and pave like it's an Windows installation!

```bash
sudo nix run \
    --extra-experimental-features 'nix-command flakes' \
    'github:nix-community/disko/latest#disko-install' \
    -- \
    --write-efi-boot-entries \
    --flake 'github:stooj/nix-config/full-disk-encryption#drummer' \
    --disk nvme /dev/nvme0n1
```

I'm specifically targetting the `full-disk-encryption` branch of my `nix-config` here.

<!-- TODO Hold on to your butts -->

It's downloading a lot of things...

It's got to the secrets bit - did I need to set up my yubikey to decrypt things, or is it able to use the SSH keys? Probably not. Hmm. This might not work.

```
Enter password for /dev/disk/by-partlabel/disk-nvme-sys:
```

That looks promising.

It failed.

```
Cannot read ssh key `/etc/ssh/ssh_host_ed25519_key': open `/etc/ssh/ssh_host_ed25519_key: no such file or directory

# etc
```

We aren't managing the ssh keys for the host OS yet. Hmm. I've got an unusable laptop again, so go me!

## References

- [How to use `sops-nix` when first partitioning disk with `disko`? · Issue #641 · nix-community/disko](https://github.com/nix-community/disko/issues/641)
- [dm-crypt/Encrypting an entire system - ArchWiki](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)
- [disko/example/luks-lvm.nix at master · nix-community/disko](https://github.com/nix-community/disko/blob/master/example/luks-lvm.nix)
- [Nix flakes](https://zero-to-nix.com/concepts/flakes)
- [Nix flakes - Flake references](https://zero-to-nix.com/concepts/flakes#references)
