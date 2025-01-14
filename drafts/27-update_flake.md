Title: Update the system using flakes
Date: 2024-12-04T08:02:40
Category: NixOS

Last time I did the nix version of a `dist-upgrade` - when a new release comes out NixOS only supports the previous version for 2 months. 

During releases, there are still security fixes and bugfixes to get, which involves updating the flake hashes like this:

```bash
nix flake update
```

<!-- TODO Link to commit 54e8612 -->

And apply the changes:

```bash
sudo nixos-rebuild switch --flake .
```

I didn't bother with a branch for this, oops. But I'll be doing it a lot.

# Reference

- [NixOS 24.11 released | Blog | Nix & NixOS](https://nixos.org/blog/announcements/2024/nixos-2405/)
- [NixOS 24.05 released | Blog | Nix & NixOS](https://nixos.org/blog/announcements/2024/nixos-2411/)
