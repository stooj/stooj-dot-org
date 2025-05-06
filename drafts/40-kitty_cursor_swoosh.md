Title: Kitty cursor swoosh
Date: 2025-05-06T09:09:40
Category: NixOS

Woah! How cool does neovide look though? Have you seen the cursor swoosh thing?

<!-- TODO Insert image 40-neovide_animated_cursor.gif -->

Image curtesy of neovide docs.

I wonder if I can get that for my kitty terminal? I [can](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_trail)??

Kitty.

Is.

Brilliant.

<!-- TODO Link to commit 538e516 -->

That _works_, but it doesn't have the super-smooth cursor movement for single characters, it only zooms about when I move more than one cell at a time.

<!-- TODO Link to commit 303223a -->

Fixed it. Cursor movement is now buttery smooth. Unlike my typing.

<!-- TODO Insert image 40-kitty_animated_cursor.gif -->

By the way, that gif was recorded with [peek](https://github.com/phw/peek), that I used inside of a `nix shell`:

```bash
nix shell nixpkgs#peek --command peek
```

```bash
cd ~/code/nix/nix-config/
git checkout main
git merge kitty-cursor-swoosh
```

# References

- [Features - Neovide](https://neovide.dev/features.html)
- [kitty.conf - kitty](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_trail)
- [phw/peek: Simple animated GIF screen recorder with an easy to use interface](https://github.com/phw/peek)
