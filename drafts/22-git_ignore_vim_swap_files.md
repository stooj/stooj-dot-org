Title: Git ignore files: vim swap files
Date: 2024-11-24T21:47:50
Category: NixOS

OK, now that I've moved from `proteus` to `drummer` entirely those vim swap files are driving me crazy.

I mean, they are great! I prefer if they lived somewhere else, and I find an undo file way more useful (see a few posts back where it saved my butt) but the quickest fix for now is to tell git to ignore those files.

While I'm here, I may as well split git out into it's own module as well. I'll do that first.

Hmm.

The git config is very _definitely_ stooj related though, so calling it `git.nix` in the root of the configuration directory is just going to clash when we do pindy's configuration. 

<!-- TODO Link to commit dd3a378 -->

Phew, busy commit, but it's just moving stuff around. Nothing new has been added, and nothing should really change between this generation and the last.

# References
