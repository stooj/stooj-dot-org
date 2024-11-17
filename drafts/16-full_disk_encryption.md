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

## Installation attempt #1

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

Fun fact, the installation succeeded! But the secrets didn't so I can't log in
because there are no user passwords set. I could boot into single user mode
again and fix this, but that's not the experience I'm wanting here. The idea is
to recreate a working environment from scratch (assuming GitHub and wherever I'm
storing my password store still exists, and the Nix cache probably. And the
internet).

## Installation attempt #2

So lets try that again. Boot into the live USB, set up the network. See above.

Then log out of root so I'm back at the regular user:

```
[nixos@nixos:~]$
```

Right, how do I do this?
I can't manually set it up because I need the pcscd service running and you can't install that in a nix-shell.

Can I have nixos modules in a `nix-shell`? Like, can I have `programs.gnupg.enable` in a `nix-shell` or a `devshell` flake?

I don't think so. 🤬

I have a mad idea.

## Installation attempt #3

Shut down `drummer` and back to `proteus`.

```
wget https://mirror.bytemark.co.uk/archlinux/iso/2024.11.01/archlinux-2024.11.01-x86_64.iso
sudo ddrescue --force --odirect archlinux-2024.11.01-x86_64.iso /dev/sda
```

Yup, downloading and ArchLinux live disk. Running to what I know.

Wrote the image to my USB and booted `drummer` into an Arch live session. The networking is a bit different - it uses `iwctl`:

```bash
iwctl --passphrase DefinitelyTheWirelessPassword station wlan0 connect rentalflat
```

Right, now to install some things

```bash
pacman --sync --refresh
pacman --sync git gnupg pcsc-tools wget pass
```

Enable the service (this is what tripped me in the NixOS live environment)

```bash
systemctl start pcscd.service
```

Can I see my Yubikey?

```bash
gpg --card-status
```

Yes!!

```
Reader ......: Yubico YubiKey OTP FIDO CCID 00 00
```

Import my key and trust it

```bash
gpg --card-edit
```

```
fetch
```

```bash
gpg --edit-key 843B1ADFEC5BDC38
```

```
trust
5
y
```

Grab DrDuh's [hardened configuration](https://github.com/drduh/config/blob/master/gpg.conf) as documented in their [yubikey guide](http://drduh.github.io/YubiKey-Guide/#using-yubikey) and the [gpg-agent.conf](https://raw.githubusercontent.com/drduh/config/master/gpg-agent.conf).

```bash
cd ~/.gnupg
wget https://raw.githubusercontent.com/drduh/config/master/gpg.conf
wget https://raw.githubusercontent.com/drduh/config/master/gpg-agent.conf
```

And replace the default SSH agent with GPG by adding the following to `~/.zshrc` (the Arch live environment uses ZSH as default)

```bash
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
```

Time to try clone my password store:

```bash
cd
git clone git@code.ginstoo.net:stooj/pass-store .password-store
```

Didn't work.

```
sign_and_send_pubkey: signing failed: agent refused operation
```

Force an agent restart/refresh/something

```bash
gpg-connect-agent updatestartuptty /bye
```

Try again:

```bash
git clone git@code.ginstoo.net:stooj/pass-store .password-store
```

Yay! It cloned. And `pass test/test` works! (I have a test password that I use to test that pass is working).

OK, here's some magic. First:

```bash
sudo pacman --sync nix
```

Aaaand I ran out of space on the liveUSB installation.

## Installation attempt #4

<!-- TODO Insert what's your great idea this time gif-->

I really hoped I could do this whole installation on a single machine. I'm pretty sure **it can be done**, but perhaps not with a vanilla NixOS liveUSB. I'd have to create a custom one. I guess that's do-able but it means I need one more thing to hand for a total disaster recovery situation.

The good news in my new plan is that I don't need to use Arch. So I'm off to download a NixOS iso and write it to my USB stick again. BRB.

```bash
wget https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso
sudo ddrescue --force --odirect latest-nixos-minimal-x86_64-linux.iso /dev/sda
```

Boot `drummer` with the liveUSB, connect to the wireless **again**, then set a temporary password for `root` so I can SSH in.

```bash
sudo --login
wpa_cli
# etc etc
passwd
ip address show wlp0s20f3  # to get the IP address of `drummer`
# It's 192.168.1.141
```

Now, back to `proteus`:

<!-- TODO How to install nix on KDE neon? With extra-experimental-features -->
<!-- TODO Check if you need to install sops and sops-nix as well -->

I'm going to use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere), which will let me install nixos on `drummer` via SSH from `proteus`. It does the `disko` partitioning, and handles secrets, and lets me seed the new installation with `drummer`'s SSH key.

There's a wee bit of setup to do on `proteus` though. Plugged my yubikey into proteus first.

1. Create a temp directory to keep the SSH key:
   ```bash
   temp=$(mktemp -d)
   ```
2. Create the directory structure for the SSH keys:
   ```bash
   install -d -m755 "$temp/etc/ssh"
   ```
3. Grab the ssh key from my password store and put it in the temp directory:
   ```bash
   pass machines/drummer/ssh/key > "$temp/etc/ssh/ssh_host_ed25519_key"
   ```
4. Fix the permissions of the ssh key:
   ```bash
   chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
   ```

Cool, now I have a directory tree for the SSH key ready to copy across to the new installation on `drummer`. Time to do it. Hopefully I don't need to start a section called "Installation attempt #5".

```bash
cd code/unmanaged/nix-config
git pull --all
git checkout full-disk-encryption
```

<!-- TODO Insert "And here we go" gif -->

Time to try nixos-anywhere:

```bash
nix run \
   --extra-experimental-features 'nix-command flakes' \
   github:nix-community/nixos-anywhere \
   -- \
   --extra-files "$temp" \
   --flake ".#drummer" root@192.168.1.141
```

I got asked for the (temporary) root pass a couple of times, then for what I want to set the luks passphase to. That seems promising.

Woah! Drummer rebooted. And aksed me for a luks passphrase. And I can log in! And vim is installed. And it's connected to the wireless. And `mr checkout` worked. And `gpg --list-keys` shows my GPG key with ultimate trust!

Time for a cocktail. Wait! Got to tidy up that temp directory first:

```bash
echo $temp  # Check it's still set to something
rm -rf $temp  # TODO is there a better way of only deleting this if it's set?
```

And merge my branch (I'm still on `drummer`):

```bash
cd ~/code/nix/nix-config
git checkout main
git merge origin/full-disk-encryption
git push
```

## References

- [How to use `sops-nix` when first partitioning disk with `disko`? · Issue #641 · nix-community/disko](https://github.com/nix-community/disko/issues/641)
- [dm-crypt/Encrypting an entire system - ArchWiki](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)
- [disko/example/luks-lvm.nix at master · nix-community/disko](https://github.com/nix-community/disko/blob/master/example/luks-lvm.nix)
- [Nix flakes](https://zero-to-nix.com/concepts/flakes)
- [Nix flakes - Flake references](https://zero-to-nix.com/concepts/flakes#references)
- [NixOS modules - NixOS Wiki](https://nixos.wiki/wiki/NixOS_modules)
- [YubiKey-Guide | Guide to using YubiKey for GnuPG and SSH](http://drduh.github.io/YubiKey-Guide/#using-yubikey)
- [iwd - ArchWiki](https://wiki.archlinux.org/title/Iwd#iwctl)
- [nix-community/nixos-anywhere: install nixos everywhere via ssh]](https://github.com/nix-community/nixos-anywhere)
