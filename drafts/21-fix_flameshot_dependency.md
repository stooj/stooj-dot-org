Title: Fix flameshot dependency and split out the config
Date: 2024-11-24T21:15:00
Category: NixOS

Welcome to `drummer`! Wow, it needs some work.

<!-- TODO insert 21-fix_flameshot_dependency-01-screenshot_of_desktop.png -->

Something that's been really bugging me is that flameshot dependency in the global configuration.

1. It's in the global configuration.
2. It's contextless. If you read `configuration.nix`, you'll probably ask *WHY* is it there? What's it for? Flameshot isn't there, so is that just another bollocks comment that's out of date?

Good news though! I found [home.packages](https://nix-community.github.io/home-manager/options.xhtml#opt-home.packages), which lets you add a list of packages to include in the home-manager generation. Perfect, that'll get it out of the system configuration at least.

<!-- TODO Link to commit 6b4193d -->

It's still a bit contextless though. Time for a wee bit of restructuring.

<!-- TODO Link to commit 98d0a01 -->

Cool - that's most of the flameshot configuration in it's own self-contained little unit. The keybindings are still in i3wm though, and it's tough to say where they "belong". Could I put them in the flameshot configuration? Would that break things? This is NixOS, changes are fearless.

<!-- TODO Link to commit c896d5d -->

Lol no, that overwrote all of the keybindings in the `stooj.nix` with just the three in `flameshot.nix`. Taking screenshots is useful, but not at the expense of everything else.

```bash
git revert HEAD
```

Never mind. Make the comment a bit more useful though.

<!-- TODO Link to commit c504d79 -->

```bash
cd ~/code/nix/nix-config
git checkout main
git merge fix-flameshot-dependency
```

# References

- [home.packages](https://nix-community.github.io/home-manager/options.xhtml#opt-home.packages)
- [How to set up a configuration for multiple users/machines?](https://nix-community.github.io/home-manager/index.xhtml#_how_to_set_up_a_configuration_for_multiple_users_machines)
