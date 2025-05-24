Title: Upgrade day
Date: 2025-05-25T00:05:33
Category: NixOS

[NixOS 25.05 has been released](https://nixos.org/blog/announcements/2025/nixos-2505/)!

```bash
cd ~/code/nix/nix-config
git checkout -b upgrade-to-25.05
```

<!-- TODO Link to commit fbd27bf -->

Run `nix flake update` to get the updated `flake.lock`

<!-- TODO Link to commit 8a122f1 -->

And apply the config to find out any breaking changes:

```bash
sudo nixos-rebuild switch --flake .
```

```
error: The top-level konsole alias has been removed.

Please explicitly use kdePackages.konsole for the latest Qt 6-based version,
or libsForQt5.konsole for the deprecated Qt 5 version.

Note that Qt 5 versions of most KDE software will be removed in NixOS 25.11.
```

<!-- TODO Link to commit e7f7e4f -->

Run the switch again and see what else is in store for us:

```
evaluation warning: The option `plugins.neorg.modules' defined in `/nix/store/wdrfzxq7plmbx6kqyz5sb9ik04961dhk-source/home/stooj/neovim/plugins/documentation/neorg.nix' has been renamed to `plugins.neorg.settings.load'.

evaluation warning: stooj profile: The option `plugins.neorg.modules' defined in `/nix/store/wdrfzxq7plmbx6kqyz5sb9ik04961dhk-source/home/stooj/neovim/plugins/documentation/neorg.nix' has been renamed to `plugins.neorg.settings.load'.

error: nerdfonts has been separated into individual font packages under the namespace nerd-fonts.
 For example change:
   fonts.packages = [
     ...
     (pkgs.nerdfonts.override { fonts = [ "0xproto" "DroidSansMono" ]; })
   ]
 to
   fonts.packages = [
     ...
     pkgs.nerd-fonts._0xproto
     pkgs.nerd-fonts.droid-sans-mono
   ]
 or for all fonts
   fonts.packages = [ ... ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts)
```

<!-- TODO Link to commit c666b8b -->

And for the evaluation warnings:

<!-- TODO Link to commit 63b3ff7 -->

```bash
cat /etc/issue
```

```
<<< Welcome to NixOS 25.05.20250522.55d1f92 (\m) - \l >>>
```

That's pretty amazing.

Yay! We did it!

```bash
cd ~/code/nix/nix-config/
git checkout main
git merge upgrade-to-25.05
```

# References

- [NixOS 25.05 released | Blog | Nix & NixOS](https://nixos.org/blog/announcements/2025/nixos-2505/)
