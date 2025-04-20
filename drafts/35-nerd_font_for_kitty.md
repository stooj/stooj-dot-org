Title: Nerd font for kitty
Date: 2025-04-15T22:30:20
Category: NixOS

```bash
cd ~/code/nix/nix-config
git checkout -b nerd-font-for-kitty
```

I need fancy terminal fonts. I **only** need them installed on workstations, but the same could be said about [qutebrowser](https://qutebrowser.org/) and I didn't deal with that at the time.

All that to say that I'm going to _ignore_ "only include this on workstations" just now and continue to treat my config like it's targeting a single machine (drummer).

The configuration for including nerd-fonts has undergone a couple of revisions and there is a new one due in 25.05, but we aren't there yet.

First thing to do is to [pick a font](https://www.nerdfonts.com/font-downloads). I'd like something that has obvious differences between `oO0` and `iIlL1`. Zeros with something in the middle to show it's a zero, and serifs or something to differentiate between an `l` and a `1`.

Hah! [Hurmit/Hermit](https://pcaro.es/hermit/)  is kinda funky looking. Is it in the [list in the repo](https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/shas.nix)? Yes, but called `Hermit`.

<!-- TODO Link to commit 5ca857d -->

Still getting that neovim devicons warning. I'll get to it.

According to `fc-match Monospace` (See [Font configuration - ArchWiki](https://wiki.archlinux.org/title/Font_configuration#Query_the_current_settings)) I'm currently using `DejaVu Sans Mono`.

Now to [set the font in kitty](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.kitty.font).

Accoding to fc-list I've now got a collection of hurmit fonts:

```bash
fc-list | grep --ignore-case --extended-regexp '(hermit|hurmit)' | cut -d: -f2
```

```
 Hurmit Nerd Font Propo,Hurmit Nerd Font Propo Light
 Hurmit Nerd Font
 Hurmit Nerd Font Propo
 Hurmit Nerd Font
 Hurmit Nerd Font Mono
 Hurmit Nerd Font Mono,Hurmit Nerd Font Mono Light
 Hurmit Nerd Font Mono
 Hurmit Nerd Font Mono,Hurmit Nerd Font Mono Light
 Hurmit Nerd Font Propo
 Hurmit Nerd Font Propo,Hurmit Nerd Font Propo Light
 Hurmit Nerd Font Mono
 Hurmit Nerd Font Mono
 Hurmit Nerd Font,Hurmit Nerd Font Light
 Hurmit Nerd Font
 Hurmit Nerd Font,Hurmit Nerd Font Light
 Hurmit Nerd Font Propo
 Hurmit Nerd Font
 Hurmit Nerd Font Propo
```

According to the [nerd-font hurmit readme](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hermit/README.md#which-font):

- Nerd Font Mono is the regular monospaced font
- Nerd Font Propo is the proportional font
- Nerd Font has larger icons, which sounds nice.

<!-- TODO Link to commit f19e922 -->

<!-- TODO Insert image 35-hurmit_font.png -->

`fc-match` still thinks I'm using "DejaVu Sans", but I'm definitely not. I suppose it's probably still the X default.

That's all done. Back to vim.

```bash
cd ~/code/nix/nix-config
git checkout main
git merge nerd-font-for-kitty
```

# References

- [Nerd Fonts - Iconic font aggregator, glyphs/icons collection, & fonts patcher](https://www.nerdfonts.com/#home)
- [Fonts - NixOS Wiki](https://nixos.wiki/wiki/Fonts)
- [Nerd Fonts - Iconic font aggregator, glyphs/icons collection, & fonts patcher](https://www.nerdfonts.com/font-downloads)
- [Hermit | Pablo J. Caro Martín](https://pcaro.es/hermit/)
- [nixpkgs/pkgs/data/fonts/nerdfonts/shas.nix at nixos-24.11 · NixOS/nixpkgs](https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/shas.nix)
- [Appendix A. - programs.kitty.fonts Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.kitty.font)
- [Font configuration - ArchWiki](https://wiki.archlinux.org/title/Font_configuration#Query_the_current_settings)
- [nerd-fonts/patched-fonts/Hermit/README.md at master · ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hermit/README.md)
