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

- It _will_ support Getting Things Done (some day maybe)
- It might support Taskwarrior?
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

Next I need to create a workspace to hold my norg files. That's going to be a little more involved because I want it to be version controlled. I'm going to host it on my personal git forge rather than GitHub so it doesn't need to be managed with Pulumi just now.

I'll let neorg create it to begin with and then sort out the gitification. Neorg is going to need a bunch of extra configuration, so time to make room:

<!-- TODO Link to commit 7623f6f -->

The configuration for neorg is a little messy because I need to pass in empty attribute sets but _force_ them to be passed to neovim.

For example, setting the defaults to be the defaults:

<!-- TODO Link to commit 3df7680 -->

Whoops, apparently I introduced a typo `neorg` → `neorga` at some point? Ah, in `7623f6f`.

<!-- TODO Link to commit 08b2803 -->

Turn on neorg's completion source and then add that source to `cmp`:

<!-- TODO Link to commit eed502f -->

All very well, but I need a workspace to actually **test** that things are working.

<!-- TODO Link to commit adc5f52 -->

Neorg has automatically created the directory for me, and if I run `Neorg index` it'll take me to `~/code/docs/wiki/index.norg`.

<!-- TODO Insert image 41-hello_neorg.png -->

Brilliant. I've got neorg installed and I've got a directory to store my notes in. I'll chuck it in a git repo and send it to my git forge:

```bash
cd ~/code/docs/wiki
git init
# Oops. TODO: git config --global init.defaultBranch main
git branch --move main
git add .
git commit --message "Initial commit"
git remote add origin git@code.ginstoo.net:stooj/wiki.git
git push --set-upstream origin main
```

Now that repo should be added to the mr config:

<!-- TODO Link to commit 7c640ff -->

More neorg to do:

> The concealer module converts verbose markup elements into beautified icons for your viewing pleasure.

Sounds good. Let's do this.

<!-- TODO Link to commit c25257a -->

<!-- TODO Insert image 41-neorg_concealer.png -->

Very pretty. I think I'd like neovim's `conceallevel` to be set to `2` for neorg files though.

This is going to need an extra `programs.nixvim` section, so as usual I'll make a nice wee `NOOP` commit to minimise the diff on the actual upcoming change.

<!-- TODO Link to commit 199664c -->

Now I can use `nixvim`'s `files` option to generate vim config files into my configuration. It's in the `ftplugin` directory, meaning it'll match based on filetype. It's called `norg.lua` so it'll automatically apply if I open a `norg` file in vim (you can check what filetype you've got by running `set ft ?` (or `:echo &filetype` too. TIL)).

<!-- TODO Link to commit 35dadb3 -->

And it'll configure norg files to have to the (local) option `conceallevel=2`. See the difference?

<!-- TODO Insert image 41-norg_concealer_with_conceallevel.png -->

While I'm here, there are a couple of other nice wee changes I'd like to make to vim's configuration for `norg` files.

First, I don't want vim to insert linebreaks when I hit a certain length of line. Lines can be as long as they want to be.

> !NOTE
> I actually _don't_ like this setting. Human eyes are terrible at reading long lines of text (especially mine) so I like to limit everything to 80 characters. But it makes it much easier to copy and paste text into legacy programs like web browsers etc.

<!-- TODO Link to commit b68f497 -->

But horizontal scrolling is awful in any circumstance, so wrap lines that are longer than the window.

<!-- TODO Link to commit 94479e1 -->

This still looks exicrible, as you can see from this screenshot. Look at where neovim is wrapping stuff!

<!-- TODO Insert image 41-norg_line_wrapping_horror.png -->

Look at where the words are being split:

```
espec
ially

lo
ng
```

Nonsense.

It's vim though. There's a setting to fix that.

<!-- TODO Link to commit 8b91ea8 -->

<!-- TODO Insert image 41-norg_line_wrapping_fixed.png -->

That's much nicer.

Last wee wrapping fix is the `breakindent` and the `breakindentopt` options.

The `breakindent` option wraps lines so they start at the same level as their previous line.

`breakindent` off (assuming the line is wrapped at the word "and"):

```
   I am indented and
wrapped as well.
```

`breakindent` on:

```
   I am indented and
   wrapped as well.
```

<!-- TODO Link to commit 3fedbf1 -->

And the `breakindentopt "shift:2"` option indents following lines just a little bit more, which I prefer the look of:

`breakindentopt=shift:2` off (assuming the line is wrapped at the word "and"):

```
   I am indented and
     wrapped as well.
```

<!-- TODO Link to commit ce93d86 -->

<!-- TODO Insert image 41-norg_line_break_indenting.png -->

I'd like most of these settings for markdown files as well. The question is "where to put it?"

<!-- TODO Link to commit 830bcb0 -->

That'll do. And I want the same configuration as I had for neorg:

<!-- TODO Link to commit d461ac3 -->

Neorg has the ability to automatically inject metadata at the top of files. It's brilliant for auto-updating modified dates, so I'm having that please.

<!-- TODO Link to commit 9988bf4 -->

- `type = auto` means "generate the metadata if it isn't there. So it'll always be created.
- `timezone = "utc"`, I _think_ I want all the times to be in New Eden UTC rather than local time. I'll see how this works out.
- `update_date = true` means "change the updated date field automatically". Very nice.

<!-- TODO Insert image 41-norg_metadata_generated.png -->

That just appeared at the top of my file when I reopened it.

Now that I have metadata, there's another module that I'd like to add: [`core.summary`](https://github.com/nvim-neorg/neorg/wiki/Summary). This little gem parses the metadata of every `norg` file and populates `index.norg` automatically, filing everything according to category.

<!-- TODO Link to commit f545692 -->

Write some notes, make sure each one has a `title`, a `description`, and a list of `categories` and then run `:Neorg generate-workspace-summary` on a heading in `index.norg`. Magical.

The last thing for now is enabling the [`core.journal`](https://github.com/nvim-neorg/neorg/wiki/Journal) module for diary entries. I use these occasionally and the `generate-workspace-summary` might make them more useful so long as I keep the categories up-to-date.

I like my posts to be nested rather than all chucked into a single directory, so I've added the `nested` strategy to the configuration. And it's nicer than having another `__empty = null;` config option.

<!-- TODO Link to commit e5b6515 -->

There's probably more I want to do with neorg but I'll deal with that when I need it. Right now I have a repo to keep my notes and a nice UI to write them.

```bash
cd ~/code/nix/nix-config/
git checkout main
git merge notes-of-neorg
```

Yay! We did it!

# References

- [neorg - nixvim docs](https://nix-community.github.io/nixvim/24.11/plugins/neorg/index.html?highlight=neorg#pluginsneorgenable)
- [norg-specs/1.0-specification.norg at main · nvim-neorg/norg-specs](https://github.com/nvim-neorg/norg-specs/blob/main/1.0-specification.norg)
- [Defaults · nvim-neorg/neorg Wiki](https://github.com/nvim-neorg/neorg/wiki/Defaults)
- [Completion · nvim-neorg/neorg Wiki](https://github.com/nvim-neorg/neorg/wiki/Completion)
- [Nvim Cmp · nvim-neorg/neorg Wiki](https://github.com/nvim-neorg/neorg/wiki/Nvim-Cmp)
- [Dirman · nvim-neorg/neorg Wiki](https://github.com/nvim-neorg/neorg/wiki/Dirman)
- [Concealer · nvim-neorg/neorg Wiki](https://github.com/nvim-neorg/neorg/wiki/Concealer)
- [Line length - Wikipedia](https://en.wikipedia.org/wiki/Line_length)
- [Metagen · nvim-neorg/neorg Wiki](https://github.com/nvim-neorg/neorg/wiki/Metagen)
- [Summary · don't know how much Invim-neorg/neorg Wiki](https://github.com/nvim-neorg/neorg/wiki/Summary)
  [Journal · nvim-neorg/neorg Wiki](https://github.com/nvim-neorg/neorg/wiki/Journal)
