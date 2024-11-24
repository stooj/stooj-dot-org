Title: Adding the blog to drummer
Date: 2024-11-24T19:44:29
Category: NixOS

This'll be a quick one I think. I've been writing this blog on `proteus`, and Pindy wants her laptop back, so it's time to start using `drummer` full-time. That should speed up the cadence of these posts as well, because I have to get stuff done.

There's a million things missing still, but only one blocker: I need to manage this blog repo in the nix-config.

I've already got almost everything set up for this, but I'm still going to use a branch just because I would like everything to come in branches.

```bash
cd ~/code/nix/nix-config
git checkout -b add-blog-repo
```

<!-- TODO Link to commit 4f15126 -->

That's it. Apply it and run `mr` in the home directory:

```bash
cd ~/code/nix/nix-config
sudo nixos-rebuild switch --flake .
pushd ~
mr checkout
popd
```

All done

```bash
cd ~/code/nix/nix-config
git checkout main
git merge add-blog-repo
```
