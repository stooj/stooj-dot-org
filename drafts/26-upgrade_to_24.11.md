Title: Upgrade to 24.11
Date: 2024-12-03T22:50:55
Category: NixOS

I've been looking through the nix options and nixpkgs and I've realised I'm not running the latest release any more! 24.11 happened! It's time to `dist-upgrade`. Ooof, this is probably going to take ages.

<!-- TODO Link to commit  01ef242 -->

That's it?? That's all I need to do??

```bash
sudo nixos-rebuild switch --flake .
```

Oh, maybe not. I've gotten some evaluation warnings that I should fix. Still, that was *amazingly* stressless.

```
trace: evaluation warning: The option `programs.bash.enableCompletion' defined in `/nix/store/z3p9kwy5z7rgpa7m62g2h5q0gykgisbi-source/bash.nix' has been renamed to `programs.bash.completion.enable'.
trace: evaluation warning: programs.vim.defaultEditor will only work if programs.vim.enable is enabled, which will be enforced after the 24.11 release
```

Shouldn't take long.

First off, my `flake.lock` file was automatically updated with the new hashes. Here it is, but if you are following along at home you shouldn't copy and paste this ;)

<!-- TODO Link to commit 11a8200 -->

And fix the bash warning:

<!-- TODO Link to commit a52f4c1 -->

And the vim warning:

<!-- TODO Link to commit cf58164 -->

Update complete. That was kind of amazing. And if it had gone completely librarian-poo, I would just roll back to a previous generation.

```bash
cd ~/code/nix/nix-config
git checkout main
git merge upgrade-to-24.11
git branch -d upgrade-to-24.11
```

# Resources

- [Appendix B. Release Notes (24.11)](https://nixos.org/manual/nixos/stable/release-notes#sec-release-24.11)
