Title: Fix the NixWiki link in Qutebrowser
Date: 2025-07-03T12:32:48
Category: NixOS

I want a couple of palate cleansers. That might not be possible with nix though, because there has been some drama.

The wiki was _forked_ for reasonable technical reasons. See [Why is there a new wiki? What is with nixos.wiki?](https://wiki.nixos.org/wiki/FAQ#Why_is_there_a_new_wiki?_What_is_with_nixos.wiki). My qutebrowser configuration still points to the old one, so I can quickly fix that.

```bash
cd ~/code/nix/nix-config
git checkout -b fix-nix-wiki-link
```

<!-- TODO Link to commit 34cdb71 -->

Simple.

```bash
cd ~/code/nix/nix-config
git checkout main
git merge fix-nix-wiki-link
```
