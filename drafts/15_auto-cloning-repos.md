Title: Auto cloning repos
Date: 2024-11-15T12:26:39
Category: NixOS

- [x] Disk partitioning and formatting
- [x] Root user password
- [x] Wireless network connection details for `rentalflat`
- [x] Passwords for `pindy` and `stooj`
- [ ] SSH known hosts file maybe.
- [ ] `/home/stooj/code/nix/` directory
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever
- [x] Git user configuration
- [x] GPG pubring

I like my home directory to have a lot of git repositories already cloned and ready to go, so I want that to be automated. That's slightly outside the scope of Nix though, because Nix is about creating static read-only configuration; I want these repos to be usable and modifiable.

So I'm going to need another tool to auto-clone repositories, and as an extra bonus get a nice way to manage repos in bulk. I've found a [Joey Hess](https://joeyh.name/) project called [myrepos](https://myrepos.branchable.com/), which is infuriatingly abbreviated to `mr` and is a nightmare to search for on the internet. I like it though; it's "simple" and scalable. This ought to tick off two items in the list.

Getting the syntax of mr just so is a bit of a pain, so I'm going to cheat with a `nix-shell`:

```bash
cd ~/code/unmanaged/nix-config
nix-shell --packages mr --run "mr register"
```

This creates `~/.mrconfig`:

```ini
[code/unmanaged/nix-config]
checkout = git clone 'git@github.com:stooj/nix-config.git' 'nix-config'
```

Delete that file again, we don't want it and we don't need it.

```bash
rm ~/.mrconfig
```

(It's a pity that [XDG directories](https://myrepos.branchable.com/forum/Support_for_XDG__95__CONFIG__95__HOME_would_be_nice/) aren't supported)

Anyway, now to add it to the configuration. I don't want it in my `unmanaged` directory, obviously.

<!-- TODO Link to commit 4d90d15 -->

Deploy the changes

```bash
cd ~/code/unmanaged/nix-config
sudo nixos-rebuild switch --flake .
```

And test that it worked:

```bash
cd ~
mr checkout
```

```
mr checkout: /home/stooj/code/nix/nix-config
Cloning into 'nix-config'...
remote: Enumerating objects: 234, done.
remote: Counting objects: 100% (234/234), done.
remote: Compressing objects: 100% (117/117), done.
remote: Total 234 (delta 133), reused 216 (delta 115), pack-reused 0 (from 0)
Receiving objects: 100% (234/234), 31.18 KiB | 638.00 KiB/s, done.
Resolving deltas: 100% (133/133), done.

mr checkout: finished (1 ok)
```

Cool! It made the parent directory and everything!

- [x] Disk partitioning and formatting
- [x] Root user password
- [x] Wireless network connection details for `rentalflat`
- [x] Passwords for `pindy` and `stooj`
- [ ] SSH known hosts file maybe.
- [x] `/home/stooj/code/nix/` directory
- [x] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever
- [x] Git user configuration
- [x] GPG pubring

There's only one thing left here!

Hmm. As a test, what happens if I delete `~/.ssh/known_hosts` and `~/code/nix` directory, then try to run `mr` again.

```bash
cd
rm ~/.ssh/known_hosts
rm -rf ~/code/nix
mr checkout
```

```
mr checkout: /home/stooj/code/nix/nix-config
Cloning into 'nix-config'...
The authenticity of host 'github.com (140.82.121.4)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Ah yes. That's what I was expecting.

There isn't a nice way of managing the `known_hosts` file in Home Manager on a per-user basis, but I don't think I'd want to anyway. There **is** a way to do it in the system configuration with [programs.ssh.knownHosts](https://search.nixos.org/options?channel=24.05&show=programs.ssh.knownHosts). I'm going to use `services.openssh.knownHosts` instead so all the ssh configuration is in the same place, but it's an alias of `programs.ssh.knownHosts`

<!-- TODO Link to commit 5afa262 -->

Testing time:

```bash
# Deploy the changes
cd ~/code/unmanaged/nix-config
sudo nixos-rebuild switch --flake .

# Tidy up files I don't want to use or want to be recreated
cd
rm -rf ~/code/nix
rm ~/.ssh/known_hosts

mr checkout
```

Did it ask to confirm the fingerprint? No! Woohoo!

Time to switch from my repo in the `unmanaged` directory to the new fully-managed one in the `nix` directory

1. Make sure everything in `unmanaged` is committed and pushed to the remote:
   ```bash
   git -C ~/code/unmanaged/nix-config push --all
   ```
2. Use `mr` to pull the latest commits to the `nix` directory:
   ```bash
   cd
   mr update
   ```
3. Delete the `unmanaged` directory
   ```bash
   rm -rf ~/code/unmanaged/nix-config
   ```

- [x] Disk partitioning and formatting
- [x] Root user password
- [x] Wireless network connection details for `rentalflat`
- [x] Passwords for `pindy` and `stooj`
- [x] SSH known hosts file maybe.
- [x] `/home/stooj/code/nix/` directory
- [x] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever
- [x] Git user configuration
- [x] GPG pubring

Inbox Zero or something  🕴️

## References

- [myrepos](https://myrepos.branchable.com/)
- [programs.mr - Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.mr.enable)
- [Support for XDG_CONFIG_HOME would be nice](https://myrepos.branchable.com/forum/Support_for_XDG__95__CONFIG__95__HOME_would_be_nice/)
- [programs.ssh.knownHosts](https://search.nixos.org/options?channel=24.05&show=programs.ssh.knownHosts)
