Title: GPG and Git configuration
Date: 2024-11-14T20:57:06
Category: NixOS

Here are the things that I need to capture in my configuration:

- [x] Disk partitioning and formatting
- [x] Root user password
- [x] Wireless network connection details for `rentalflat`
- [x] Passwords for `pindy` and `stooj`
- [ ] SSH known hosts file maybe.
- [ ] `/home/stooj/code/nix/` directory
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever
- [ ] Git user configuration
- [ ] GPG pubring

Back in <!-- TODO Add link --> "Setting up Secrets" I I manually imported my GPG
public key into the keyring by curling it from keybase. Can't be doing _that_
any more, so I'm going to store a copy in the repo.

## GPG

```bash
mkdir --parents ~/code/unmanaged/nix-config/keys
curl https://keybase.io/stooj/pgp_keys.asc?fingerprint=243848098eb57dbea8df8000834b1adfec5bdc38 >> ~/code/unmanaged/nix-config/keys/stooj.asc
```

<!-- TODO Link to commit ff0b5e7 -->

Now I manage (and trust) that key with home-manager:

<!-- TODO Link to commit d4ae902 -->

Woah. That was easy and very elegant.

Now Git!

## Git

My git configuration is going to have a lot more nonsense in it, but this step
is all about replacing the manual setup I did in <!-- TODO Add link --> "Setting
up Secrets".

<!-- TODO Link to commit bdd9ab6 -->

This will create `~/.config/git/config` with:

```
[user]
        email = "scj@stooj.org"
        name = "stoo johnston"

```

Fantoush! (RIP my inbox btw).

- [x] Disk partitioning and formatting
- [x] Root user password
- [x] Wireless network connection details for `rentalflat`
- [x] Passwords for `pindy` and `stooj`
- [ ] SSH known hosts file maybe.
- [ ] `/home/stooj/code/nix/` directory
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever
- [x] Git user configuration
- [x] GPG pubring

That felt good.

# References

- [My New Network (and encrypting secrets with sops) - sam@samleathers.com ~ $](https://samleathers.com/posts/2022-02-11-my-new-network-and-sops.html)
- [programs.gpg - Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.gpg.enable)
- [programs.git - Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.enable)
