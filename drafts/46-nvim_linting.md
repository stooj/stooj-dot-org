Title: neovim linting
Date: 2025-05-23T08:44:59
Category: NixOS

Previously, on stooj_dot_org:

> I don't **care** about style guides. I don't **care** about per-project configuration
> I want linting.
> I want neovim to tell me all the dumb stuff I've done.
> No new branch because I'm lazy.

Bye bye biome.

<!-- TODO Link to commit 5b48475 -->

I dunno where to put my linting configuration. Conform is in the `lsp` directory but maybe it's not really lsp-related... Stuff it. It's going straight in `plugins` for now. I want to be working on norgolith right now, not this.

<!-- TODO Link to commit c7a3c9e -->

Enable the `nvim-lint` plugin:

<!-- TODO Link to commit ae95927 -->

Now I need to find some linters. My go-to list for this has always been [ale](https://github.com/dense-analysis/ale), which very helpfully has a separate help document for each language, [including css](https://github.com/dense-analysis/ale/blob/master/doc/ale-css.txt).

What have we got?

- [CSpell](https://cspell.org/). That's a spell checker. It might be useful, but not what I'm after.
- [CSS Beautifier](https://codebeautify.org/css-beautify-minify). If anything, that'd be something I'd add to my conform configuration. Still not a linter.
- [FECS](http://fecs.baidu.com/). A front-end code style suite. This looks like a wrapper for other tools, so it wouldn't actually solve my problem.
- [prettier](https://prettier.io/). Oh, it's you again! And you're still a formatter!
- [Stylelint](https://stylelint.io/). A mighty CSS linter that helps you avoid errors and enforce conventions. That sounds very promising. Wait, and it also sounds very familiar...
- There's also [vscode-langservers-extracted](https://github.com/hrsh7th/vscode-langservers-extracted).

But this _Stylelint_ thing. `nvim_lsp` supports that and I thought it looked promising before. Why didn't I try it in the last post?

Well, it's getting tried now.

<!-- TODO Link to commit d492c00 -->

Still nothing in a broken css file. **headdesks**. Where are [the docs](https://github.com/bmatcuk/stylelint-lsp)?

OK:

> If neither config nor configFile are specified, stylelint will attempt to automatically find a config file based on the location of the file you are editing.

That _might_ be what is going wrong. I've no config, and no config file.

Make way!

<!-- TODO Link to commit 8dbfb8a -->

What if I use the `lint` plugin to lint the file, and the lsp to install the binary?

<!-- TODO Link to commit 185058f -->

<!-- TODO Insert image 46-stylelint_unhelpful_error.png -->

That is not particularly helpful.

```bash
git revert 185058f
```

<!-- TODO Link to commit c1afcda -->

This is kind of infuriating. I must be misunderstanding the ecosystem completely or something, because this feels like an obvious requirement rather than some weird corner case.

There was this plugin called [vim-polyglot](https://github.com/sheerun/vim-polyglot) and it was a mega-pack of hand-selected indentation and syntax files for any language you could want. It was great because you got an almost perfect (pre-treesitter of course) highlighting experience with _any_ filetype, and with no extra configuration. I want that but for basic linting. I suppose it might be something I need to make, although at this rate it'll be a retirement project for me.

Stuff it. What about just grabbing a linter that I _know_ works and try to get `nvim-lint` to use that.

Check it works first:

```bash
nix shell nixpkgs#csslint
cd ~/code/docs/stooj-dot-org/mysite
csslint assets/style.css
```

```
csslint: There are 3 problems in /home/stooj/code/docs/stooj-dot-org/mysite/assets/style.css.

style.css
1: warning at line 1, col 1
Rule doesn't have all its properties in alphabetical order.
body{

style.css
2: error at line 13, col 1
Expected RBRACE at line 13, col 1.


style.css
3: error at line 13, col 1
Expected RBRACE at line 13, col 1.
```

Fantastic, `csslint` linted a file and told me it sucked. THAT'S what I want.

So can I shove that into `nvim-lint`?

<!-- TODO Link to commit 419a2b2 -->

<!-- TODO Insert image 46-csslint_error.png -->

Nope. The linter doesn't exist. Because I need to specify the command maybe? I've seen that in other people's configurations.

<!-- TODO Link to commit 4967b46 -->

Eeep, that gives me an evaluation warning:

```
evaluation warning: getExe: Package "csslint-1.0.5" does not have the meta.mainProgram attribute. We'll assume that the main program has the same name for now, but this behavior is deprecated, because it leads to surprising errors when the assumption does not hold. If the package has a main program, please set `meta.mainProgram` in its definition to make this warning go away. Otherwise, if the package does not have a main program, or if you don't control its definition, use getExe' to specify the name to the program, such as lib.getExe' foo "bar".
```

It's a problem with the way it's packaged. Don't care, the binary is definitely called `csslint` because it worked in that `nix shell` above.

<!-- TODO Insert image 46-csslint_not_found.png -->

Nope, still not working. I've just realised that `csslint` is supported in `Ale`, but not in `nvim-lint`. Still, I feel good about this approach. There's my old friend Biome. I've come full-circle.

<!-- TODO Link to commit c6e2a56 -->

<!-- TODO Insert image 46-biome_showing_an_error.png -->

Halle-fecking-lujah.

...

And yet... nggggh... it only lints on save. Can I make that a bit more aggressive?

<!-- TODO Link to commit aa0b5bf -->

Much better. Now it triggers when I leave insert mode.

I'd also like it to trigger when I open a file. I _think_ this'll do that (according to [autocmd.txt](https://neovim.io/doc/user/autocmd.html#BufWinEnter)).

<!-- TODO Link to commit 2607015 -->

Lovely! I opened my test file and immediately got my error message.

Thank crivvens for that. This is the first post I've not enjoyed, because that was very frustrating.

Luckily, the next one is going to be great.

```bash
cd ~/code/nix/nix-config
git checkout main
git merge converting-to-html
```

# References

- [mfussenegger/nvim-lint: An asynchronous linter plugin for Neovim complementary to the built-in Language Server Protocol support.](https://github.com/mfussenegger/nvim-lint)
- [Neve/config/languages/nvim-lint.nix at 12055e2b1bc97335cef27052c5a0ed5fd5d417e4 · redyf/Neve](https://github.com/redyf/Neve/blob/12055e2b1bc97335cef27052c5a0ed5fd5d417e4/config/languages/nvim-lint.nix#L4)
- [dense-analysis/ale: Check syntax in Vim/Neovim asynchronously and fix files, with Language Server Protocol (LSP) support](https://github.com/dense-analysis/ale)
- [ale/doc/ale-css.txt at master · dense-analysis/ale](https://github.com/dense-analysis/ale/blob/master/doc/ale-css.txt)
- [CSpell | CSpell](https://cspell.org/)
- [CSS Formatter, CSS Beautifier and CSS Minifier Online tool](https://codebeautify.org/css-beautify-minify)
- [FECS - Front End Code Style Suite](http://fecs.baidu.com/)
- [Prettier · Opinionated Code Formatter · Prettier](https://prettier.io/)
- [Home | Stylelint](https://stylelint.io/)
- [hrsh7th/vscode-langservers-extracted: vscode-langservers bin collection.](https://github.com/hrsh7th/vscode-langservers-extracted)
- [bmatcuk/stylelint-lsp: A stylelint Language Server](https://github.com/bmatcuk/stylelint-lsp)
- [sheerun/vim-polyglot: A solid language pack for Vim.](https://github.com/sheerun/vim-polyglot)
- [Autocmd - Neovim docs](https://neovim.io/doc/user/autocmd.html#BufWinEnter)
