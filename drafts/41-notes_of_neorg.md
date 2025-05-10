Title: Notes of Neorg
Date: 2025-05-07T21:54:35
Category: NixOS

This _is_ nice, drummer is almost nice enough to be a daily driver at this point: I've got a nice web browser and a nice editor. Everything one needs to accomplish anything.

Now that it's ready to be properly used, it's time to add some **content**. Not just configuring the laptop, but actually adding things that I will use day to day.

The first thing I'd like (because everything else will build upon it) is a personal knowledge base. The arguments and relative merits of the (hundreds) of different solutions is almost as heated as editor wars, but I have some specific requirements that exclude some of the more popular mainstream options:

- Self-hosted
- Actually, probably just local files
- Plain text
- No database backend
- Not markdown
- Description/definition lists

Here's what I've used in the past:

- [MoinMoinWiki - MoinMoin](https://moinmo.in/)
- [Sphinx — Sphinx documentation](https://www.sphinx-doc.org/en/master/index.html)
- [Vimwiki by vimwiki](http://vimwiki.github.io/)
- Notion
- [Outline – Team knowledge base & wiki](https://www.getoutline.com/)
- [Logseq: A privacy-first, open-source knowledge base](https://logseq.com/)
- [Obsidian - Sharpen your thinking](https://obsidian.md/)

Here's what I want to try now:

- [nvim-neorg/neorg: Modernity meets insane extensibility. The future of organizing your life in Neovim.](https://github.com/nvim-neorg/neorg)

Just hear me out.

The project has been going for at least four years, but still has a lot of (exciting) work to do. There isn't a great ecosystem yet, and it doesn't really support Getting Things Done (yet) or Taskwarrior or anything. It doesn't have the ability to (directly) output to HTML, so the best way of _reading_ your documents are in neovim, and the developers are absurdly smart people who started this project and then decided that the needed to re-architect _the entire world_ in order to build neorg. So they are busy doing that just now. _sigh_

But:

- It _will_ support Getting Things Done
- It looks _superb_ in neovim
- It is designed around it's own markup language (hold on, that sounds bad but listen) whose manifesto makes a really good argument about why markdown sucks.

I'm making a bet that neorg will become something very special.

```bash
cd ~/code/nix/nix-config
git checkout -b notes-of-neorg
```

Neorg used to be an absolute _pig_ to install.

<!-- TODO Link to commit b62abfd -->

Installed. 🥰

Next I need to create a workspace to hold my norg files. That's going to be a little more involved because I want it to be version controlled, which means making a repo, which means revisiting my pulumi project from way back in <!-- TODO Link to post 06_pulumi-first-steps.md -->.

Which makes me realise that I don't have that pulumi project on drummer. Or pulumi.

I'll get the code first, which is still on GitHub (but I have _plans_).

<!-- TODO Link to commit 18f92c5 -->

```bash
cd
mr checkout
```

```
mr checkout: /home/stooj/code/pulumi/higara
Cloning into 'pulumi-higara'...
remote: Enumerating objects: 34, done.
remote: Counting objects: 100% (34/34), done.
remote: Compressing objects: 100% (17/17), done.
remote: Total 34 (delta 16), reused 33 (delta 15), pack-reused 0 (from 0)
Receiving objects: 100% (34/34), 33.95 KiB | 409.00 KiB/s, done.
Resolving deltas: 100% (16/16), done.
mr checkout: failed to chdir to /home/stooj/code/pulumi/higara/: No such file or directory

mr checkout: finished (1 failed; 3 skipped)
```

That failed. It checked out the code but it threw an error, because... the paths don't match. I told mr the directory was called `higara` but git cloned the repo into `pulumi-higara`.

Try again:

```bash
cd ~/code/pulumi
rm -rf pulumi-higara
```

<!-- TODO Link to commit 700001f -->

```bash
cd
mr checkout
```

That's better. But pulumi will need installed along with the dependencies and such.

This is going to need another branch.

Merging `notes-of-neorg` and starting another branch.

Yay! We did it! Sort of!

# References

- [norg-specs/1.0-specification.norg at main · nvim-neorg/norg-specs](https://github.com/nvim-neorg/norg-specs/blob/main/1.0-specification.norg)
