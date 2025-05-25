Title: Even more neovim config for the web
Date: 2025-05-25T08:01:57
Category: NixOS

Well, that was a fun little interlude. I'm being sarcastic, I got very mad about all that `css` nonsense. But I've slept, upgraded to 25.05 _utterly painlessly_ and I'm feeling good again.

To demonstrate **how** good I'm feeling, I'm going to throw some more web development stuff at my neovim configuration.

```bash
cd ~/code/nix/nix-config
git checkout -b even-more-web-dev
```

I want linting for:

- `html` (`html-lsp` or `superhtml`)
- `tera` (I don't think there's a `tera` linter but a `jinja` one might work just as well)

And I want formatting for:

- `css`
- `html`
- `tera`?

First I'm going to tidy up a bit of the mess from my thrashing against `css`:

<!-- TODO Link to commit 5fc8ce7 -->

And that list of LSPs is going to get larger, so I want it sorted in alphabetical order:

<!-- TODO Link to commit 8e47c49 -->

I'm going to enable it and it's _just gonna work_.

<!-- TODO insert positive waves gif -->

<!-- TODO Link to commit 63cd894 -->

<!-- TODO Insert image 48-superhtml_showing_errors.png -->

OK, it's not perfect. It's showing errors but not showing what they are. It'll show if I turn on `virtual_text` manually though. I wonder why that's turned off?

```
:lua vim.diagnostic.config({virtual_text = true})
```

<!-- TODO Insert image 48-superhtml_virtual_text_enabled.png -->

Huh. `virtual_text` is disabled globally now, I just checked it with that `css` file.

According to the [manual](https://nix-community.github.io/nixvim/24.11/NeovimOptions/index.html?highlight=dia#diagnostics) it should be easy to fix, but I want to do a bit of a no-op shuffle on my `lsp.nix` file first.

<!-- TODO Link to commit 0e647a6 -->

I just wrapped everything in a single `programs.nixvim` block there rather than having it repeated twice.

There's two options in the manual:

- `virtual_lines`
- `virtual_text`

What's the difference? I don't know. Look at the man page? Nah, try each and see what they look like.

<!-- TODO Link to commit c1b36ca -->

<!-- TODO Insert image 48-diagnostics_virtual_line.png -->

Oooh, I _think_ I like that.

For jinja, there's `djlint` but I don't think it's an LSP-compatible tool. There's also `jinja_lsp`, so let's try that:

<!-- TODO Link to commit b75a5b3 -->

```
error: Nixvim (plugins.lsp.servers.jinja_lsp.package): No package is known for jinja_lsp, to resolve this either:
 - install externally and set this option to `null`
 - or provide a derviation to install this package
```

Oof.

> Package to use for jinja_lsp. Nixpkgs does not include this package, and as such an external derivation or null must be provided.

Never mind then.

```bash
git revert b75a5b3
```

 <!-- TODO Link to commit ce26748 -->

Hahah! Harper has started trying to correct my spelling again!

 <!-- TODO Insert image 48-harper_spell_suggestions.png -->

I remember this. It's because the case changed for `harper` configuration, remember?

 <!-- TODO link to 38-markdown-formatting.md -->

 <!-- TODO Link to commit dec1afe -->

[`djlint` is supported by `nvim-lint`](https://github.com/mfussenegger/nvim-lint).

<!-- TODO Link to commit 0d62324 -->

Neovim automatically detects my template files as `htmldjango` so I can take advantage of that by only targeting `htmldjango` files for the linter.

<!-- TODO Insert image 48-djlint_working_fine.png -->

That's working fine. The syntax highlighting is a bit bored after that `now(format="%Y")` section.

Hmm, it looks better if I disable treesitter highlighting:

<!-- TODO Insert image 48-treesitter_highlight_disabled.png -->

Dunno. Might be a difference between real `jinja` and `tera`? I'll look into it again some other day. For now I have linting for `html`, `css`, and `htmldjango`. Lovely.

<!-- TODO Link to commit 46d1f07 -->

Run `:ConformInfo` to confirm :)

<!-- TODO Insert image 48-djlint_formatting_ready.png -->

Oh, I like it when it's painless.

Can I use biome for formatting or will it complain that I don't have a configuration file?

<!-- TODO Link to commit bba5b98 -->

Nope, that worked beautifully.

<!-- TODO Insert image 48-biome_formatted_css.png -->

I think I can skip the `html` formatting just now, `djlint` is handling what I'll need.

Yay! We did it! See what positive waves can do?

```bash
cd ~/code/nix/nix-config
git checkout main
git merge even-more-web-dev
```

# References

- [superhtml - nixvim docs](https://nix-community.github.io/nixvim/24.11/plugins/lsp/servers/superhtml/index.html)
- [Neovim Options - nixvim docs](https://nix-community.github.io/nixvim/24.11/NeovimOptions/index.html?highlight=dia#diagnostics)
- [mfussenegger/nvim-lint: An asynchronous linter plugin for Neovim complementary to the built-in Language Server Protocol support.](https://github.com/mfussenegger/nvim-lint)
