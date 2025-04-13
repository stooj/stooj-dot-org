Title: Some tidying up (qutebrowser)
Date: 2025-04-13T21:46:06
Category: NixOS

```bash
cd ~/code/nix/nix-config
git checkout -b cleaning-up-qutebrowser-config
```

When I was doing the kitty configuration, I noticed that all of my qutebrowser configuration is stuffed into the `home/stooj/default.nix` file. That's easily fixed.

<!-- TODO Link to commit a676e03 -->

Hardly worth it's own post to be honest, but this is the path I've chosen to walk!


```bash
cd ~/code/nix/nix-config
git checkout main
git merge cleaning-up-qutebrowser-config
git branch -d cleaning-up-qutebrowser-config
```
