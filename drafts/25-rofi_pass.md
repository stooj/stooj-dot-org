Title: Rofi Pass
Date: 2024-12-03T22:19:21
Category: NixOS

I haven't integrated one of my favourite programs into i3 yet: [carnager/rofi-pass: rofi frontend for pass](https://github.com/carnager/rofi-pass). It's unmaintained now which is quite sad, but hopefully [carnager](https://github.com/carnager) is having fun doing something else.

I'm going to be mucking about with my i3 configuration a little, so this is a good opportunity to tidy it up. I'm going to make a directory/module that contains all the i3 stuff and has a single entry point, because my dunst configuration doesn't make much sense to use unless I'm also using i3.

<!-- TODO Link to commit dbbec61 -->

And I can move rofi into a separate file too, and add rofi-pass while I'm at it.
Wait, I used the word "and" to describe a git commit message. I'm going to split it into two commits:

<!-- TODO Link to commit ff38f0b -->

And

<!-- TODO Link to commit a339dbd -->

Move dunst into a separate file too:

<!-- TODO Link to commit c080272 -->

And i3wm

<!-- TODO Link to commit 74dabf5 -->

And now the rofi-pass bindings. How do you find out where something actually is again? *searches BASH history*. Ah yes.

```bash
readlink --canonicalize $(which rofi-pass)
```

<!-- TODO Link to commit da351cf -->

Nice, now I can press `Meta+p` and get rofi-pass. That'll make signing into things a lot easier.

Not a lot of changes, but the i3 configuration is lot tidier now, I think. It'd be cool if I could move the `rofi`-related i3 bindings into the `rofi` file, but maybe that doesn't make sense... :thinking_face:

```bash
cd ~/code/nix/nix-config
git checkout main
git merge rofi-pass
git branch -d rofi-pass
```

# References

- [programs.rofi.pass.enable](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.rofi.pass.enable)
- [NixOS Search - Packages - rofi-pass](https://search.nixos.org/packages?channel=24.11&show=rofi-pass&from=0&size=50&sort=relevance&type=packages&query=rofi-pass)
