Title: Git ignore files: vim swap files
Date: 2024-11-24T21:47:50
Category: NixOS

OK, now that I've moved from `proteus` to `drummer` entirely those vim swap files are driving me crazy.

I mean, they are great! I prefer if they lived somewhere else, and I find an undo file way more useful (see a few posts back where it saved my butt) but the quickest fix for now is to tell git to ignore those files.

While I'm here, I may as well split git out into it's own module as well. I'll do that first.

```bash
cd ~/code/nix/nix-config
git checkout -b git-ignore-vim-swap-files
git push
```
Hmm.

The git config is very _definitely_ stooj related though, so calling it `git.nix` in the root of the configuration directory is just going to clash when we do pindy's configuration. So I'll make a `common` directory for home config that we share, and `stooj` and `pindy` directories for individual settings.

<!-- TODO Link to commit dd3a378 -->

Phew, busy commit, but it's just moving stuff around. Nothing new has been added, and nothing should really change between this generation and the last.

Next is to split up the git configuration; there's common config and there's stoo-specific config. I should add pindy's config as well.

<!-- TODO Link to commit 1fdd53f -->

Here I've moved the shared git configuration (only `enabled = true` for now) into it's own file that is shared between pindy and I, then created a file each for pindy-specific or stoo-specific config.

It's going to be a _little_ tedious remembering to add imports for all users every time we add a new common configuration though. Luckily the filename `default.nix` has special meaning.

<!-- TODO Link to commit 6052560 -->

Instead of importing each file in the `common` directory for each user, I'm importing `common` (which is `common/default.nix`) which imports all the files contained in the `common` directory. This also fixes me forgetting to include flameshot for pindy.

I can do a bit more tidying because every electron counts.

<!-- TODO Link to commit 0911e19 -->

With all that out of the way, it's time to finally fix the git ignore file.

<!-- TODO Link to commit 2b129e4 -->

Easy. Now it's set for both pindy and stooj. And nix merges all these separate `program.git` blocks into a single configuration; it's brilliant.

```bash
git checkout main
git merge git-ignore-vim-swap-files
git push
```

# References

- [programs.git.ignores](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.ignores)
