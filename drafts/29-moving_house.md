Title: Setting up secrets
Date: 2025-03-20T22:32:59
Category: NixOS

I've been taking my time with this whole process and it shows. I've moved to a new rental place. A new flat means a new wireless configuration.

Shouldn't take too long.

```bash
cd ~/code/nix/nix-config
git checkout -b moving-house
```

I'm not going to bother keeping the SSID and passphrase for the old place so I can reuse most of the existing configuration.

Just need to change the SSID:

<!-- TODO Link to commit c3b0679 -->

And the passphrase:

```bash
nix shell nixpkgs#sops --command sops secrets.yaml
```

<!-- TODO Link to commit a060acb -->

```bash
sudo nixos-rebuild switch --flake .
```

Turn off my phone hotspot and.... connected! Painless!

And yet...

There's two networks here; a 2.5Ghz one and a 5Ghz one. May as well throw in the 5Ghz one as well, using the same password.

<!-- TODO Link to commit b7d6f31 -->

OK, all done. See? Painless.

```bash
cd ~/code/nix/nix-config
git checkout main
git merge moving-house
git branch -d moving-house
``
