Title: Bitwarden and snippets
Date: 2025-05-15T21:24:45
Category: NixOS

```bash
cd ~/code/nix/nix-config
git checkout -b bitwarden-and-snippets
```

I need to install bitwarden. That's a single line in my config, so not worth a post.

But there's something about writing these posts that annoys me; there's a `Date:` line in the front matter of every post that I've been carefully inserting the current date and time into. I don't know if I'll end up keeping/using it; I _vaguely_ remember that [Pelican](https://getpelican.com/) uses it.

It there is one thing that computers are good at, it's counting how many seconds there have been since the [epoch](<https://en.wikipedia.org/wiki/Epoch_(computing)>). Actually they _aren't_ good at it, as we are all going to find out in [2038](https://en.wikipedia.org/wiki/Year_2038_problem), but we'll have annihilated ourselves by then anyway so it won't matter a hoot.

But still, why am I manually putting in the date? I could shell out, I suppose:

```
:r !date --rfc-3339=seconds
```

But I've got this fancy snippet engine, so I'm going to use that instead.

I want this snippet to work for _all_ filetypes, so it's going in `all.lua`.

Here's a single snippet using a [`partial`](https://github.com/L3MON4D3/LuaSnip/blob/c1851d5c519611dfc451b6582961b2602e0af89b/DOC.md#partial) snippet which runs a function and inserts whatever the output of that function is. Like `os.date`.

<!-- TODO Link to commit 0b3b801 -->

I also need to make sure the file is symlinked to the right place, like the markdown file was:

<!-- TODO Link to commit a4c91cc -->

Smeg. I've a typo in my snippet.

<!-- TODO Link to commit 8a44651 -->

Fixed. I need to sort out a lua lsp at some point.

Cool! Now if I type `date` and let `cmp` expand it for me, I get `2025-05-15`. Should be trivial to add another one:

<!-- TODO Link to commit 44c7b1c -->

Smeg! The comma.

<!-- TODO Link to commit 8f9d3b1 -->

Fixed again. Although when these lua snippets don't parse properly, `harper_ls`'s spellchecker turns back on and reminds me that I probably need to have a spellchecker enabled at all times.

But now if I type `datetime` and let `cmp` do it's thing, I get `2025-05-15 215939`.

<!-- TODO Insert image 43-datetime_snippet.png -->

Huh, that's not _quite_ the format I want. I want ISO 8601 format:

<!-- TODO Link to commit 6225f02 -->

<!-- TODO Insert image 43-datetime_snippet_iso_8601.png -->

`2025-05-15T22:04:48`

Nice.

Eh, bitwarden. This is just going to be an installation; there's nothing to "manage" about it other than the authentication and I don't trust myself to get that correct.

<!-- TODO Link to commit 6d35de5 -->

Oh, wild! There's a [bitwarden terraform provider](https://registry.terraform.io/providers/maxlaverse/bitwarden/latest) that lets your manage your bitwarden vault. So I could manage it with Pulumi. 🤔 There's an interesting experiment for some day.

Oh, and install tree as well. Tree is great.

<!-- TODO Link to commit 07ac829 -->

Yay! We did it!

```bash
cd ~/code/nix/nix-config
git checkout main
git merge bitwarden-and-snippets
```

# References

- [Pelican – A Python Static Site Generator](https://getpelican.com/)
- [Pelican – A Python Static Site Generator](https://getpelican.com/)
- [maxlaverse/bitwarden | Terraform Registry](https://registry.terraform.io/providers/maxlaverse/bitwarden/latest)
