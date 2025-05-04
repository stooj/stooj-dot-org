Title: A gui for vim
Date: 2025-05-04T21:30:55
Category: NixOS

Every now and then I need a version of neovim that is wrapped in a gui application. I'd like neovim please, using the same configuration as my usual terminal-based one. There are [a lot of them](https://github.com/neovim/neovim/wiki/Related-projects#gui).

```bash
cd ~/code/nix/nix-config/
git checkout -b gui-for-vim
```

I'm going to try out [Neovide](https://neovide.dev/) because it's just before neovim in the [home-manager appendix](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovide.enable) so I thought I'd try it out.

[firenvim](https://github.com/glacambre/firenvim) looks really interesting though for when I start using Firefox.

<!-- TODO Link to commit 7d10f80 -->

# References

- [Related projects · neovim/neovim Wiki](https://github.com/neovim/neovim/wiki/Related-projects#gui)
- [Neovide - Neovide](https://neovide.dev/)
- [Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovide.enable)
- [glacambre/firenvim: Embed Neovim in Chrome, Firefox & others.](https://github.com/glacambre/firenvim?tab=readme-ov-file)
