Title: Setting up secrets
Date: 2024-10-23T14:18:11
Category: NixOS

Where were we? Oh, yeah.

Enter [sops-nix](https://github.com/Mic92/sops-nix).

It's a way to keep secrets in your Nix config.
And [sops](https://github.com/getsops/sops#2usage) Secrets OPerationS is a tool for managing secrets.

[^NOTE]:
    Sops can use different backends, it'd be cool if it could use ESC.
    Sops-nix can only use `age` and `GPG` though[^1]. 🙁

Huh. First of all it's time to _actually_ start using drummer for the git commit
messages, even though that will add some things to our "imperative things to
fix" list.

<!-- TODO Link to commit 5810ac1 -->

And rebuild:

```bash
sudo nixos-rebuild switch --flake .
```

Now that we have git, I'm going to copy across my nix-config git mirror (yes,
I've been keeping two copies of the repo, one on proteus with git and one on
drummer with nothing).

```bash
# On proteus
scp -r ~/code/unmanaged/nix-config 192.168.1.5:
```

Now on drummer:

```bash
mkdir --parents code/unmanaged
mv nx-config code/unmanaged
```

And we need to tell git who we are:

```bash
cd code/unmanaged/nix-config
git config user.name "stoo johnston"
git config user.email "scj@stooj.org"
```

- [ ] Disk partitioning and formatting (needs flakes ✓)
- [ ] Root user password (needs secrets ✗)
- [ ] Wireless network connection details for `rentalflat` (needs secrets ✗)
- [ ] Passwords for `pindy` and `stooj` (needs secrets ✗)
- [ ] SSH known hosts file maybe. (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/` directory (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever (needs
      user configuration ✗)
- [ ] Git user configuration (needs user configuration ✗)

Time to make sops-nix available to our configuration.

Add it as an input in the `flake.nix` file:

<!-- TODO Link to commit b495539 -->

Note that we haven't **installed** sops here. You can, but I'm not going to
bother because the official docs don't bother with it. Maybe in the future when
we build a dev shell or something.

Next I need to get the fingerprint of my GPG key using `gpg --list-secret-keys`.
Don't stress, the fingerprint is public info.

And finally I add that to a `.sops.yaml` file.

<!-- TODO Link to commit aa46d3d -->

I'm using a YAML anchor called `stooj_yubikey` here so I don't have to paste the
value of the fingerprint all over the file.

The creation rule says use the yubikey key for "any files called `*secrets.yaml$`".

(So `my-secrets.yaml` would work, but `secrets.yaml1` would not)

Next up, creating a secrets file. Remember how I said I wasn't going to install
`sops`? Because we can start an ephemeral shell with the package like this:

```bash
nix-shell --packages sops --run "sops secrets.yaml"
```

```
Error encrypting the data key with one or more master keys: [failed to encrypt
new data key with master key "243848098EB57DBEA8DF8000834B1ADFEC5BDC38": could
not encrypt data key with PGP key: github.com/ProtonMail/go-crypto/openpgp
error: key with fingerprint '243848098EB57DBEA8DF8000834B1ADFEC5BDC38' is not
available in keyring; GnuPG binary error: failed to encrypt sops data key with
pgp: ]
```

Except it didn't work. Because I haven't installed GPG yet.

Can we do it by just including gpg in our shell?

```bash
nix-shell --packages sops gnupg --run "sops secrets.yaml"
```

```
gpg: 243848098EB57DBEA8DF8000834B1ADFEC5BDC38: skipped: No public key
gpg: [stdin]: encryption failed: No public key]
```

No. Because the gnupg agent isn't running.

Hmm. We're going to need to install gpg and then trust the key.

<!-- TODO Link to commit 555bb9d -->

```bash
sudo nixos-rebuild switch --flake .
```

Check that we can see the yubikey

```bash
gpg --card-status
```

```
Reader ...........: things
Application ID ...: Some things
Application type .: OpenPGP
Version ..........: 3.4
Manufacturer .....: Yubico
Serial number ....: a number
Name of cardholder: Stoo Johnston
Language prefs ...: en
Salutation .......:
URL of public key : https://keybase.io/stooj/pgp_keys.asc?fingerprint=243848098eb57dbea8df8000834b1adfec5bdc38
# etc etc
```

Nice!

Now to put the public key into our local keystore. We should add that to the
list:

- [ ] Disk partitioning and formatting (needs flakes ✓)
- [ ] Root user password (needs secrets ✗)
- [ ] Wireless network connection details for `rentalflat` (needs secrets ✗)
- [ ] Passwords for `pindy` and `stooj` (needs secrets ✗)
- [ ] SSH known hosts file maybe. (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/` directory (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever (needs
      user configuration ✗)
- [ ] Git user configuration (needs user configuration ✗)
- [ ] GPG pubring

Because I've got the `URL of public key` in my yubikey, it's really easy to
fetch the key:

```
gpg --card-edit
fetch
quit
```

And we need it trusted:

```
gpg --edit-key 834B1ADFEC5BDC38
trust
5
quit
```

Now, let's try that again:

```bash
nix-shell --packages sops --run "sops secrets.yaml"
```

It worked! But something has gone horribly wrong and we need to fix it as soon
as possible:

> nano is the default editor

Ctrl-x to exit nano without making any changes.

[There's a `defaultEditor` setting for vim](https://search.nixos.org/options?channel=24.05&show=programs.vim.defaultEditor&from=0&size=50&sort=relevance&type=packages&query=programs.vim.defaultEditor). Presumably this will set it for root,
but will it set it for other users?

<!-- TODO Link to commit d3dd6cf -->

Apply the changes.

```bash
sudo nixos-rebuild switch --flake .
```

And try again:

```bash
nix-shell --packages sops --run "sops secrets.yaml"
```

Nope. Looking at [the source](https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/programs/vim.nix), it sets the `EDITOR` environment variable. Try logging out and logging back in.

And try again:

```bash
nix-shell --packages sops --run "sops secrets.yaml"
```

YES! It's vim, and a sops template file!

```
hello: Welcome to SOPS! Edit this file as you please!
example_key: example_value
# Example comment
example_array:
    - example_value1
    - example_value2
example_number: 1234.56789
example_booleans:
    - true
    - false
```

Change the content to set the `rental-flat-psk` to whatever the password is and
save:

```
rental-flat-psk: <the-password-for-the-wireless>
```

If you have a look at the raw `secrets.yaml` file, you can see it's now full of
stuff.

<!-- TODO Link to commit a14672b -->

Let's open up the decrypted version again:

```bash
nix-shell --packages sops --run "sops secrets.yaml"
```

```
Failed to get the data key required to decrypt the SOPS file.

Group 0: FAILED
  243848098EB57DBEA8DF8000834B1ADFEC5BDC38: FAILED
    - | could not decrypt data key with PGP key:
      | github.com/ProtonMail/go-crypto/openpgp error: could not
      | load secring: open /home/stooj/.gnupg/pubring.gpg: no such
      | file or directory; GnuPG binary error: failed to decrypt
      | sops data key with pgp: gpg: encrypted with rsa4096 key, ID
      | D84037CE9AEFEC5C, created 2022-09-29
      |       "Stoo Johnston (5th Generation) <scj@stooj.org>"
      | gpg: public key decryption failed: No pinentry
      | gpg: decryption failed: No pinentry

Recovery failed because no master key was able to decrypt the file. In
order for SOPS to recover the file, at least one key has to be successful,
but none were.
```

Smeg. No pinentry program, so we can't unlock the yubikey. Maybe we should
_actually read_ the [documentation](https://nixos.wiki/wiki/Yubikey).

<!-- TODO Link to commit 62a6948 -->

OK, SSH will use GPG and the GPG agent is enabled.

Apply the changes.

```bash
sudo nixos-rebuild switch --flake .
```

This'll probably need a relog, so log out and back in again.

Now to test if our SSH key is using GPG by "listing public key parameters of all
identities currently represented by the agent":

```bash
ssh-add -L
```

<!-- TODO Insert oos bingo gif -->

Now, can we decrypt the secrecy file finally?

```bash
nix-shell --packages sops --run "sops secrets.yaml"
```

No. Still no pinentry. I figured that according to
[this](https://search.nixos.org/options?channel=24.05&show=programs.gnupg.agent.pinentryPackage&from=0&size=50&sort=relevance&type=packages&query=programs.gnupg.agent)
description that `pkgs.pinentry-curses` would be included as part of the
configuration.

Maaaybe it's just the agent being funny? I could try killing the agent with
`gpg-connect-agent /bye` command or I could just reboot the machine.

Rebooting the machine fixed it, which is a shame because rebooting a machine
feels like cheating.

Anyway

```bash
nix-shell --packages sops --run "sops secrets.yaml"
```

```
rental-flat-psk: <the-password-for-the-wireless>
```

Beautiful. We have secrets! Now how do we use them?

Well, after all that nonsense, I can encrypt and decrypt secrets using my GPG
key. How is drummer going to decrypt them?

SSH keys, did I mention that before? 


---

So again: how do we use them?

It's *tricky*. The secrets aren't (necessarily) available during the nix config
"build" phase, so you can't include secret values inside nix-managed config
files. Sops-nix decrypts the files and puts them in a directory on the target
machine, and then you have to find a way of getting your configuration to
**look** at those files. You can use a templating tool to dump **an entire
file**, but then you end up with large chunks of plain configuration in your
code, rather than nix code. Yuck.

So you need a way of getting the secrets into configuration files without
relying on just hard-coding a placeholder into a big blog of toml or whatever,
and it'll vary from package to package.

systemd lets you use environment files that get resolved in unit files.
Environment files are simple to make, just a single line.


[^1]: [feature request: support for external key management · Issue #629 · Mic92/sops-nix](https://github.com/Mic92/sops-nix/issues/629)

# References

- [Mic92/sops-nix: Atomic secret provisioning for NixOS based on sops](https://github.com/Mic92/sops-nix)
- [getsops/sops: Simple and flexible tool for managing secrets](https://github.com/getsops/sops#2usage)
- [feature request: support for external key management · Issue #629 · Mic92/sops-nix](https://github.com/Mic92/sops-nix/issues/629)
- [GPG import public key from smartcard](https://yarmo.eu/blog/gpg-import-from-smartcard/)
- [NixOS Search - Options - programs.vim.defaultEditor](https://search.nixos.org/options?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=programs.vim.defaultEditor)
- [nixpkgs/nixos/modules/programs/vim.nix at nixos-24.05 · NixOS/nixpkgs](https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/programs/vim.nix)
- [Yubikey - NixOS Wiki](https://nixos.wiki/wiki/Yubikey)
- [NixOS Search - Options - programs.gnupg.agent](https://search.nixos.org/options?channel=24.05&show=programs.gnupg.agent.pinentryPackage&from=0&size=50&sort=relevance&type=packages&query=programs.gnupg.agent)
