Title: User secrets
Date: 2025-03-18T21:39:55
Category: NixOS

I got a nextcloud account with Hetzner! I've self-hosted Nextcloud for so long that I used to self-host Owncloud before the fork, but these days I'd rather have someone else manage it. They do a decent job.

One of the nice things about Nextcloud is that I use it to sync my home directory between different machines and also make everything available on my phone if I need it. It's not **ideal** because it uses a desktop application and it isn't wildly scriptable, but I've got some tricks to work around those quirks.

Before I can set it up though I'm going to need something far more fundamental for my nix setup; User Secrets.

```bash
cd ~/code/nix/nix-config
git checkout -b user-secrets
```

System secrets are decrypted using age keys, derived from SSH keys. They're also encrypted/decrypted with GPG, using a key that lives on my Yubikey. Pindy has one too, so I could use those to decrypt user secrets.

That would mean that I'd need to plug my yubikey in whenever I ran a `nixos-rebuild`. More annoyingly, I'd need to plug my Yubikey in whenever I booted the machine because home-manager would need to decrypt the secrets on boot. And I'd need physical access to any machine with user secrets, because they'd need a Yubikey plugged into them on boot. It'd be the same for Pindy.

Rubbish.

The alternative is to have another set of SSH keys and share them across all the hosts; One for pindy and one for me. This is exactly the same level of protection as the system secrets, and I'm using sops as a way to store secrets safely in a repo; not guard against users with shell access reading secrets from the filesystem.

First I need to add the `home-manager` sops module to `flake.nix`

<!-- TODO Link to commit 10eb544 -->

Ugh, and I'm going to tidy up that configuration block a bit to avoid some of the duplication.

<!-- TODO Link to commit 0e3687e -->

Time to make some ssh keys:

```bash
KEYDIR="$HOME/mykeys"
mkdir "$KEYDIR"
ssh-keygen -t ed25519 -C "pindy@localhost" -f "$KEYDIR"/key
pass insert --multiline ssh/pindy@localhost < "$KEYDIR"/key
pass insert --multiline ssh/pindy@localhost.pub < "$KEYDIR"/key.pub
rm -rf "$KEYDIR"
```

And the same for me:
```bash
KEYDIR="mykeys"
mkdir "$KEYDIR"
ssh-keygen -t ed25519 -C "stooj@localhost" -f "$KEYDIR"/key
pass insert --multiline ssh/stooj@localhost < "$KEYDIR"/key
pass insert --multiline ssh/stooj@localhost.pub < "$KEYDIR"/key.pub
rm -rf "$KEYDIR"
```

Now to add them to `.sops.yaml`... I need a cool way of doing this for my notes. I can probably use `yq` (the [go version](https://mikefarah.gitbook.io/yq), not the [python version](https://github.com/kislyuk/yq)).

Because these lines contain special characters (`&` and `*`), I need to pipe them in rather than include them in the `yq` command (there might be a way that I haven't found it. Maybe something to do with the [Set alias](https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators) operator? In the mean time, I'm adding the aliases to `.creation_roles[0].key_groups[0].age` in the _most_ shameful way. Make sure the spaces are correct.

```bash
cd ~/code/nix/nix-config
nix shell nixpkgs#ssh-to-age nixpkgs#yq-go
PUBKEY=$(echo -n "&pindy " && pass ssh/pindy@localhost.pub | ssh-to-age) yq --in-place '.keys += [env(PUBKEY)]' .sops.yaml
PUBKEY=$(echo -n "&stooj " && pass ssh/stooj@localhost.pub | ssh-to-age) yq --in-place '.keys += [env(PUBKEY)]' .sops.yaml
echo "          - *pindy" >> .sops.yaml
echo "          - *stooj" >> .sops.yaml
```

<!-- TODO Link to commit 537b47e -->

I haven't found a documented way to store SSH private keys as secrets, but what if I include the keys as **system-level** secrets and symlink them to the correct place?

```bash
nix shell nixpkgs#sops --command sops secrets.yaml
```

```
# In vim:
G  # Go to the end of the file
o  # Begin a new line below the cursor and switch to insert mode
stoojSSHKey: |<ESC>
:r !pass ssh/stooj@localhost 
v6k  # Visually select this line and the 6 above it (change 6 to suit how many lines got added by the `:r !` command
>  # indent those lines
:wq
```

And repeat for pindy.

<!-- TODO Link to commit 8450496 -->

Once `secrets.yaml` has been updated, add the files to the main configuration. There isn't a special nixos option for this, so I'm just putting the files in the right place.

<!-- TODO Link to commit bfa89c2 -->

I _think_ that's good? `pindy` and `stooj` have ssh keys that are part of the nix configuration but they're encrypted with the host ssh key, which is seeded as part of the installation step. The real test will be "can I encrypt/decrypt a user secret with the user ssh key?" And will there be a race condition when the SSH secrets haven't been added but home-manager tries to use them to decrypt things?

Sops needs to be told where to find the SSH keys to decrypt the age secrets for each user, so that needs to be added as a configuration option for each user. I _should_ be able to do that in `common`, but that means _any_ new users will have to get an ssh key so the `common` configuration works. That's maybe not a bad thing.

<!-- TODO Link to commit c7e2b9f -->

Time to test it.

Create a secrets file in stooj's home directory:

```bash
nix shell nixpkgs#sops --command sops home/stooj/secrets.yaml
```

Put in a secret called "mysecret"

Then add that secret to the configuration. It should end up in `$HOME/.config/sops-nix/secrets`

<!-- TODO Link to commit 0abd6df -->

And run `sudo nixos-rebuild switch --flake .` and see what happens... :drumroll:

Wow. It ran successfully.
And it created a file in `$HOME/.config/sops-nix/secrets` called `mysecret`.
And when I cat `mysecret` it contains the encrypted secret!

<!-- TODO Giphy of Renton ya dancer -->

Outstanding. The **real** test will be when I rebuild the machine and see what happens when the SSH key isn't there. But this seems to work!

Tidy up the test files. `git rm home/stooj/secrets.yaml` to clear out the secrets; sops doesn't like an existing empty yaml file.

<!-- TODO Link to commit bf62201 -->

What a result! I'll get to Nextcloud, but having user secrets is going to make things a lot quicker going forward. Time to merge!

```bash
cd ~/code/nix/nix-config
git checkout main
git merge user-secrets
git branch -d user-secrets
```
