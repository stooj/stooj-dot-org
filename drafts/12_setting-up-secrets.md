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

Drummer already has SSH keys for the root user, and that's the one we're going
to use for system-level secrets.

You can't actually directly use SSH keys (sops uses GPG or age), so I'm going to
have my GPG key as the "main" key for everything, and convert SSH public keys to
age keys for targeting specific machines.

```bash
nix-shell --packages ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

That command will output an age public key that we can add to the `.sops.yaml`
file.

First of all, I need to fix a mistake in the `.sops.yaml` file that I just
spotted - that nested `keys` dict shouldn't be there (even if it still works).

<!-- TODO Link to commit 98b371b -->

Right, add that age key that we generated to the `.sops.yaml` file:

<!-- TODO Link to commit cc79b55 -->

And then we regenerate our `secrets.yaml` key so that it is encrypted with both
the GPG and the age key:

```bash
nix-shell --packages sops --run "sops updatekeys secrets.yaml"
```

<!-- TODO Link to commit c1a6342 -->

OK, I think that's it. So how do we actually _use_ these secrets?

It's _tricky_. The secrets aren't (necessarily) available during the nix config
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

~~First, we use a `sops.template` to create a file that contains the secret stored
in an environment variable:~~

First, we are going to fix `flake.nix` so that sops-nix is an output (so it's
available) and add the module to our nix modules (so we can use it). Oops.

<!-- TODO Link to commit e8c593a -->

Then we're going to do a wee bit of sops configuration:

1. Set the default sops secrets file
   <!-- TODO Link to commit 30eb5e6 -->
2. Tell sops where the SSH keys are (it'll derive age keys from the ssh keys)
   <!-- TODO Link to commit e002173 -->

**Now** we can tell sops that "there is a secret called `rental-flat-psk`", and
it doesn't need any special configuration (hence the empty `{}`):

<!-- TODO Link to commit 1aee658 -->

It'll be created at `/run/secrets/rental-flat-psk`.

Then we use the `sops.templates` to embed a secret into a string that gets
written to a file. Theoretically you could write the NetworkManager profile by
hand and use a template to embed it into a giant template, but that's very ugly
and means you don't get to use declarative
`networking.networkmanager.ensureProfiles` config.

<!-- TODO Link to commit 26b5976 -->

It'll be created at `/run/secrets-rendered/wireless.env`

Then we're going to include that environment file in our NetworkManager
configuration by evaluating the `path` attribute on the `template`:

<!-- TODO Link to commit 8cb3640 -->

That'll add `EnvironmentFile=/run/secrets-rendered/wireless.env` to
`/etc/systemd/system/NetworkManager-ensure-profiles.service`

And finally after all that setup we can add the *actual* psk to the network
configuration:

<!-- TODO Link to commit 9b366f9 -->

There's ~~one~~ two other things I need to do here before this'll work.

The first is to actually _include_ the `wireless.nix` file in the configuration.
I wrote these notes as a "configure everything first and then do a big test as
the last step" which is completely stupid. What I **should** have done is
include a blank `wireless.nix` file in the configuration right at the beginning
and then make small changes and test each one to make sure everything still
worked. I'll do that going forward.

<!-- TODO Link to commit b3bdcdf -->

The second thing I need to do is apologise for doing the first thing. I'm going
to test it, but if you do commit b3bdcdf as the very first thing in this post,
you can `nixos-rebuild` at every stage and it will complete successfully.

Right. Apply the changes.

```bash
sudo nixos-rebuild switch --flake .
```

Oh! Funny story.
This has taken me a few ~~hours~~ ~~days~~ ~~weeks~~ to write, and I've
**moved** flat since I started. So I need to update the SSID of our wireless and
the PSK.

Change the SSID:
<!-- TODO Link to commit 7a5858c -->

Change the PSK using:

```bash
nix-shell --packages sops --run "sops secrets.yaml"
```

<!-- TODO Link to commit ab1871e -->

While I'm here, that ID isn't tied to a specific SSID, so I'm going to change
it:

<!-- TODO Link to commit 7dca969 -->

The ID is what shows up in the network scan list (say if you use `nmtui`).

Now for my moment of truth.

```bash
sudo nixos-rebuild switch --flake .
```

Then I'm going to manually delete any and all connections that I created
manually (run `sudo ls /etc/NetworkManager/system-connections` to get a list)

```bash
# Delete any manually configured connections
sudo nmcli connection delete DIGIFIBRA-PLUS-YkPe
sudo nmcli connection delete <ANY OTHERS I CAN SEE>

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Check I still have a network connection
ping duckduckgo.com
```

<!-- TODO Insert celebration gif -->

Right, that was a lot of work, but it's now going to be easy to add new network
connections.

Like my phone hotspot:

<!-- TODO Link to commit ece66ac -->

And the coworking space I'm at just now. I'm going to keep the SSID as a secret
as well because the SSID is a bit "google-able" and I'd rather preserve some
illusion of privacy.

<!-- TODO Link to commit e775d36 -->

---

<!-- TODO This should be recorded somewhere -->

The other thing I'm going to do is **record** the root SSH keys for drummer in
my password store, so we can use _the same keys_ when we rebuild the machine.

I don't _have_ pass installed or configured on drummer yet, which is probably an
oversight. We're going to have to put together some misguided command to pull
the ssh key over the network.

```bash
# On Proteus, which has drummer's password for stoo stored in
# `machines/drummer/stoo`:
ssh 192.168.1.5 \
    "echo $(pass machines/drummer/stoo) \
    | sudo --stdin cat /etc/ssh/ssh_host_ed25519_key" \
  | pass insert --multiline machines/drummer/ssh/key
```

This is a silly command, but it works.

1. SSH to drummer (192.168.1.5)
2. Instead of opening a normal shell, run the command wrapped in quotation
   marks:
   1. Echo the sudo password for stoo on drummer by grabbing it from my password
      store and pipe it to the next command
   2. As sudo (reading the password from standard in (the previous pipe (this
      sentence is starting to feel like LISP))) cat the SSH private key to
      stdout
3. Meanwhile, back on proteus, pipe the result of the previous command into a
   password store file (machines/drummer/ssh/key) and warn pass that it's going
   to be multiline, so store everything that gets piped to it (rather than just
   the first line).

Simple.

We need to do the same for the public key. Actually, we don't need to at all,
but I'm going to in case.

Actually, why would I bother? If you can have the private key, you can generate
a public key.

<!-- END TODO  -->

<!-- TODO DO I NEED TO DO THIS? -->

We also need to add the public key as a file in the repo, and it's going to be
an age file.

```bash
mkdir --parents ~/code/unmanaged/nix-config/keys/hosts
nix-shell --packages ssh-to-age --run \
  'cat /etc/ssh/ssh_host_ed25519_key.pub \
  | ssh-to-age -o ~/code/unmanaged/nix-config/keys/hosts/drummer.age'
```

<!-- END TODO  -->

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
- [linux - How do I run a sudo command on a remote machine using ssh? - Super User](https://superuser.com/questions/1613852/how-do-i-run-a-sudo-command-on-a-remote-machine-using-ssh)
- [linux - How to provide password directly to the sudo su -<someuser> in shell scripting - Super User](https://superuser.com/questions/1351872/how-to-provide-password-directly-to-the-sudo-su-someuser-in-shell-scripting/1351876#1351876)
- [My New Network (and encrypting secrets with sops) - sam@samleathers.com ~ $](https://samleathers.com/posts/2022-02-11-my-new-network-and-sops.html)
