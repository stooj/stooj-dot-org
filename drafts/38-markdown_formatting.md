Title: Markdown formatting
Date: 2025-04-26T21:25:20
Category: NixOS

```bash
cd ~/code/nix/nix-config
git checkout -b markdown-formatting
```

I've got two repos on drummer at the moment, `nix-config` and `stooj-dot-org`. The nix one is sorted now, I've got a Nix LSP set up and conform is formatting it with `nixfmt`. On top of that, `treefmt` is able to format the whole repo using `nix fmt`, which of course uses `nixfmt`. Of course.

There's no markdown formatting though, and while, you know... it's just markdown, there are LSPs out there. I had a look at the [nvim-lspconfig list](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md) and I could see:

- [dprint](https://github.com/dprint/dprint): Pluggable and configurable code formatting platform written in Rust. It does markdown and a bunch of other things.
- [grammarly](https://github.com/znck/grammarly): Send your file to grammarly. Discontinued, and anyway no thanks.
- [harper_ls](https://github.com/automattic/harper): The Grammar Checker for Developers. Might be interesting to fix my writing words make better.
- [htmx](https://github.com/ThePrimeagen/htmx-lsp): HTMLX but does markdown as well? From everyone's favourite Youtube superstar ThePrimeagen but I'm not writing [htmlx](https://htmx.org/) just now.
- [ltex](https://github.com/valentjn/ltex-ls): LTeX Language Server: LSP language server for LanguageTool 🔍✔️ with support for LaTeX 🎓, Markdown 📝, and others
- [ltex_plus](https://github.com/ltex-plus/ltex-ls-plus): Maybe a fork of ltex-ls?
- [markdown_oxide](https://github.com/Feel-ix-343/markdown-oxide): A Personal Knowledge Management language server. This looks _really_ interesting and might replace vimwiki for me. I'm not planning on using [Obsidian](https://obsidian.md/) though.
- [marksman](https://github.com/artempyanykh/marksman): Write Markdown with code assist and intelligence in the comfort of your favourite editor.
- [prosemd_lsp](https://github.com/kitten/prosemd-lsp): An experimental proofreading and linting language server for markdown files ✍️
- [remark_ls](https://github.com/remarkjs/remark-language-server): A language server to lint and format markdown files with [remark](https://github.com/remarkjs/remark).
- [tailwindcss](https://github.com/tailwindlabs/tailwindcss-intellisense): Intelligent Tailwind CSS tooling. Apparently supports markdown, but probably not what I'm looking for.
- [tinymist](https://github.com/Myriad-Dreamin/tinymist): Tinymist [ˈtaɪni mɪst] is an integrated language service for [Typst](https://typst.app/) [taɪpst]. Woah, typst is a possible LaTeX replacement. That needs investigating.
- [unocss](https://github.com/xna00/unocss-language-server): A language server for unocss. I don't know what unocss is, so probably not useful to me just now.
- [vale_ls](https://github.com/errata-ai/vale-ls): An implementation of the Language Server Protocol (LSP) for the [Vale](https://github.com/errata-ai/vale) command-line tool.
- [zk](https://github.com/zk-org/zk): A plain text note-taking assistant. Another vimwiki alternative. I should investigate some day.

Woah, there are a lot. I think I can narrow it down a bit though; I want two (actually three) things:

1. Code linting:
   - marksman
   - remark_ls
2. Grammar checking:
   - harper_ls
   - ltex
   - ltex_plus
   - prosemd_lsp
   - vale_ls
3. Third thing that I don't want to solve right this minute: code formatting (because that's for conform to fix)
   - dprint

## Code linting

### [Marksman](https://github.com/artempyanykh/marksman)

Oooh, this does link completion (fine) with anchor links (🤩). It treats a project as anything with a `.git` directory.

### [Remark](https://remark.js.org/)

Lints and formats markdown files, and remark can also convert markdown to html (I'd usually use pandoc for that). It can generate tables of content too.

---

I'll try marksman first, it also supports wiki links which might be useful to me.

<!-- TODO Link to commit b30ddef -->

Quit _this_ vim window with a markdown file and reopen it again. No fidget spinner :(

Check `:LspLog`:

```
[START][2025-04-26 22:35:43] LSP logging initiated
[ERROR][2025-04-26 22:35:43] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/dql5sz7187b7k0zq8ad1a1mmcy486891-marksman-2024-10-07/bin/marksman"	"stderr"	"[22:35:43 INF] <LSP Entry> Starting Marksman LSP server: {}\n"
```

Hmm, that doesn't tell me much. Marksman started but rpc is receiving an error?

Try running marksman with verbose logging turned on:

<!-- TODO Link to commit 7bb8c72 -->

Reading `:LspLog` now:

```
[START][2025-04-26 23:08:56] LSP logging initiated
[ERROR][2025-04-26 23:08:56] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/dql5sz7187b7k0zq8ad1a1mmcy486891-marksman-2024-10-07/bin/marksman"	"stderr"	"[23:08:56 INF] <LSP Entry> Starting Marksman LSP server: {}\n"
[ERROR][2025-04-26 23:08:56] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/dql5sz7187b7k0zq8ad1a1mmcy486891-marksman-2024-10-07/bin/marksman"	"stderr"	"[23:08:56 VRB] <StatusAgent> StatusAgent starting: {}\n[23:08:56 VRB] <BackgroundAgent> Preparing to start background agent: {}\n"
[ERROR][2025-04-26 23:08:56] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/dql5sz7187b7k0zq8ad1a1mmcy486891-marksman-2024-10-07/bin/marksman"	"stderr"	'[23:08:56 DBG] <MarksmanServer> Obtained workspace folders: {"workspace": ["[/home/stooj/code/docs/stooj-dot-org, { uri = \\"file:///home/stooj/code/docs/stooj-dot-org\\"\\n  data = RootPath (AbsPath \\"/home/stooj/code/docs/stooj-dot-org\\") }]"]}\n'
... etc. ...
```

That's a lot of nothing. The LSP server looks like it's working fine, but everything is showing as errors.

There's an open issue in the nixvim issue tracker about a similar error with nixd. [This comment](https://github.com/nix-community/nixvim/issues/2390#issuecomment-2408101568) suggests that it's unicode characters in the source files causing the issue.

<!-- TODO Link to commit 2a589bd -->

It didn't fix it for me though 😒.

OK, time to file a bug I think. First off, build a minimal example to check that it's not something to do with my configuration elsewhere:

<!-- TODO Link to commit a18afb4 -->

There's no `vim` alias any more, so I need to run `nvim 38-markdown_formatting.md`. Wow, I've come a long way since my vim sessions looked like this.

<!-- TODO Insert image 38-minimal_vim.png -->

Argh, no snippets any more either! :grin:

OK, what does `:LspLog` say?

```
[START][2025-04-27 15:03:05] LSP logging initiated
[ERROR][2025-04-27 15:03:05] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/dql5sz7187b7k0zq8ad1a1mmcy486891-marksman-2024-10-07/bin/marksman"	"stderr"	"[15:03:05 INF] <LSP Entry> Starting Marksman LSP server: {}\n"
```

Still the same issue. There is [this issue in the marksman repo](https://github.com/artempyanykh/marksman/issues/236). There's a suggestion in [this thread](https://github.com/artempyanykh/marksman/issues/236#issuecomment-1646976548) that's worth trying.

<!-- TODO Link to commit ba5e80a -->

That thread also recommends [prettier](https://prettier.io/) for formatting.

Wait... I've got a horrible suspicion.

> This is just the way nvim treats logs from the server, not an error per-se.

Is... is it not actually erroring? Has marksman been working fine all this time but there's nothing worthwhile to say?

What if I try a test bit of code and press `<S-k>` on the `[reference]` on the first line.

```markdown
See [reference].
[reference]: https://github.com/artempyanykh/marksman "If you can see this then marksman is working"
```

<!-- TODO Insert image 38-working_marksman.png -->

Whoops. It was working after all 😊. Move along please.

I can get rid of that minimal reproduction directory:

<!-- TODO Link to commit 2197e91 -->

And I can get rid of the extra options I used for debugging:

<!-- TODO Link to commit 7e3fe75 -->

Phew. That was a journey. What's next? Ah, yes...

## Grammar checking

I've used grammar checkers before and I love the idea, but they always want to correct my grammar inside codeblocks which is _never_ what I want.

Let's have a look at these and see what's available.

### [harper_ls](https://writewithharper.com/)

Open source, on-device only, it **does** do grammar checking on code but only for comments (nice!) and the [list of languages](https://writewithharper.com/docs/integrations/language-server#Supported-Languages) includes `nix.` It's an Automattic project... :oof:. That gives me some pause, their [founder hasn't been showering themselves in glory recently](https://en.wikipedia.org/wiki/WP_Engine#WordPress_dispute_and_lawsuit).

### [ltex](https://valentjn.github.io/ltex/) and [ltex_plus](https://ltex-plus.github.io/ltex-plus/)

Based on the commit history, `ltex_plus` is a fork of `ltex` since the latter hasn't been updated in two years. Cool, that's a good reason for a fork and refreshingly lacking in any drama.

It looks very comprehensive, and a killer feature for me is that it supports [neorg](https://github.com/nvim-neorg/neorg), which lines up with my future plans very nicely.

It claims to have extensive documentation (great), but I can't find a way to search that documentation (boo). Apart from reading the source on GitHub, which works fine I suppose. It looks like it will [ignore markdown code blocks](https://ltex-plus.github.io/ltex-plus/settings.html#ltexmarkdownnodes) as well (with a little configuration).

### [prosemd_lsp](https://github.com/kitten/prosemd-lsp)

Marked as experimental, but hasn't seen a commit in 4 years. Nah.

### [vale_ls](https://github.com/errata-ai/vale-ls)

[Vale](https://vale.sh/) also supports a lot of markup languages ([but not neorg](https://github.com/errata-ai/vale/issues/652) 🙁)

So, order of preference for trying these out is:

1. ltex_plus
2. vale_ls
3. harper_ls

### Back to ltex

The first hurdle for `ltex_plus` is that it's not available in nixvim. Well, not _yet_, it's available in the [main branch](https://nix-community.github.io/nixvim/plugins/lsp/servers/ltex_plus/index.html) but not in the version I'm using (nixos-24.11).

So let's leave that one for now, shall we?

### Vale is next

I don't like this `servers` word repeated. Fix that first.

<!-- TODO Link to commit 8f46320 -->

And turn on `vale_ls`:

<!-- TODO Link to commit 55d79f3 -->

`nixos-rebuild`, restart my neovim window and... there's an error.

```
LSP[vale_ls] missing field `Path` at line 4 column 1
```

That's because `vale` [requires a `.vale.ini`](https://vale.sh/docs/vale-ini) in the root of the project directory. Yuck! I might be working with other people's projects that don't _have_ one of them. And it's going to throw that error every time I open a markdown file? Nope. Or save a file?

<!-- TODO Insert image 38-vale_error_list.png -->

I guess we're on to harper then.

### harper

<!-- TODO Link to commit 5facc64 -->

Hurray, that was easy and it _just works_.

<!-- TODO Insert image 38-working_harper.png -->

Did I mean to spell harper that way though? Yes, yes I did. Harper uses very specific [rules](https://writewithharper.com/docs/rules) for grammar checking. I don't think I make many of those mistakes, but it might be handy to catch the odd one.

The spellchecking needs to go though. According [to the docs](https://writewithharper.com/docs/integrations/neovim#Common-Config-Changes) it's a simple addition to the lspconfig setup, but getting the `["harper-ls"]` in the configuration might be tricky because `harper_ls.settings` expects strings.

<!-- TODO Insert image 38-broken_harper_config.png -->

`"[\"harper-ls\"]"` might work?

<!-- TODO Link to commit 31bcec2 -->

It _built_ fine, and the generated lua code _looks_ OK, but I'm still getting asked if I meant to spell `lua` that way.

Here's the generated lua code:

```lua
-- LSP {{{
do
    local __lspServers = {
        { name = "nil_ls" },
        { name = "marksman" },
        {
            extraOptions = { settings = { ['["harper-ls"]'] = { linters = { SpellCheck = false } } } },
            name = "harper_ls",
        },
    }
    -- Adding lspOnAttach function to nixvim module lua table so other plugins can hook into it.
    _M.lspOnAttach = function(client, bufnr) end
    local __lspCapabilities = function()
        capabilities = vim.lsp.protocol.make_client_capabilities()

        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        return capabilities
    end

    local __setup = {
        on_attach = _M.lspOnAttach,
        capabilities = __lspCapabilities(),
    }

    for i, server in ipairs(__lspServers) do
        if type(server) == "string" then
            require("lspconfig")[server].setup(__setup)
        else
            local options = server.extraOptions

            if options == nil then
                options = __setup
            else
                options = vim.tbl_extend("keep", options, __setup)
            end

            require("lspconfig")[server.name].setup(options)
        end
    end
end
```

Is there a way of "printing out" the end config for lspconfig? Maybe this vim command will do it?

```
:lua vim.print(require("lspconfig")["harper_ls"])
```

Nice! And lookee lookee. That does _not_ look right!

<!-- TODO Insert image 38-harper_config_mistake.png -->

<!-- TODO Link to commit 23df7c5 -->

Hmm. It's _still_ showing those spelling errors. Time to check the config again, and now that I know where it is I can print it directly:

```
:lua vim.print(require("lspconfig")["harper_ls"].manager.config.settings)
```

```
{
  ["harper-ls"] = {
    linters = {
      SpellCheck = false
    }
  }
}
```

That looks _perfect_! What's going on?

What happens if I just use `extraLuaConfig` directly so I can copy and paste the example config from the docs?

<!-- TODO Link to commit d5b8311 -->

Now my `~/.config/nvim/init.lua` contains the exact same code as the docs (apart from the SentenceCapitalization. And I **did** mean to spell SentenceCapitalization that way, thanks!

```lua
require("lspconfig").harper_ls.setup({
    settings = {
        ["harper-ls"] = {
            linters = {
                SpellCheck = false,
            },
        },
    },
})
```

What about I stop being clever and just use the exact config in the docs?

<!-- TODO Link to commit c4b2b087 -->

Still not working. Hmm...

I searched the harper-ls issue tracker again, and I can across [this comment](https://github.com/Automattic/harper/issues/780#issuecomment-2683706024).

TLDR harper < v0.23.0 uses snake_case for linter names.

That took quite a while, but now it's working. Wow. Markdown lsps are a _pain_.

The last thing to do is to move the configuration back into the proper nix block instead of using raw lua code:

<!-- TODO Link to commit 1349309 -->

## Formatting

I finally made it here. The option is between [dprint](https://github.com/dprint/dprint) and [prettier](https://prettier.io/). I'm a bit done with markdown linting and formatting because it's only fecking markdown after all. I don't even like it. So this is going to be a very shallow comparison.

| Formatter | Pros            |
| --------- | --------------- |
| dprint    | written in rust |
| prettier  | nicer website   |

dprint _has_ a prettier plugin, so I could theoretically format my files with dprint which uses prettier under the covers. Because why not.

Not today though, I'm going with dprint because it's rust and I'd like more rust in my life.

The weird thing is that dprint is a language server, so it'll work like a lsp. But conform supports it. So I think the way you set this up is to set up dprint like a lsp, then tell conform that "yes, I'm using dprint, and always use the lsp".

dprint uses plugins for different languages, so how do I install plugins?

According to [myNixOS](https://mynixos.com/nixpkgs/package/dprint-plugins.dprint-plugin-markdown) (which I've never really been sure what that is) the dprint plugins are packaged like, say, python modules. So in a standard nixos config you'd say something like:

```nix
environment.systemPackages = with pkgs; [
  (dprint.withPlugins (plugins: with plugins; [
    dprint-markdown
  ]);
];
```

But what is nixvim expecting?

Try just enabling it first and see what happens.

<!-- TODO Link to commit 7b036ec -->

Nope. A few issues here:

1. Spelling messages for harper are back
2. dprint packages aren't packaged for Nixos-24.11

Undo the dprint commit first:

```bash
git revert 7b036ec
```

<!-- TODO Link to commit 74355a5 -->

And revert moving the harper config out of lua:

```bash
git revert 1349309
```

<!-- TODO Link to commit 5155241 -->

And did I not actually fix the case?

<!-- TODO Link to commit e344d0c -->

So prettier then? That one _isn't_ an LSP, so it'll go straight into the `conform` config. First make some room for other `plugins.nixvim` things by splitting line 5 into two lines:

<!-- TODO Link to commit ae3f862 -->

And `userCommands` is inside the single `programs.nixvim` block now as well. Much nicer.

That probably looks like an enormous diff. Here it is ignore whitespace changes:

```git
git show --ignore-space-change ae3f862
commit ae3f86253d565e951e1f8569f74c8fe9e7425d5e (HEAD -> markdown-formatting)
Author: stoo johnston <scj@stooj.org>
Date:   Sat May 3 22:47:23 2025 +0200

    neovim: make room for other nixvim config in conform

diff --git a/home/stooj/neovim/plugins/lsp/conform.nix b/home/stooj/neovim/plugins/lsp/conform.nix
index adbd431..eeaf410 100644
--- a/home/stooj/neovim/plugins/lsp/conform.nix
+++ b/home/stooj/neovim/plugins/lsp/conform.nix
@@ -3,7 +3,8 @@
   # conform.nvim
   # Lightweight yet powerful formatter plugin for Neovim
   # See https://github.com/stevearc/conform.nvim
-  programs.nixvim.plugins.conform-nvim = {
+  programs.nixvim = {
+    plugins.conform-nvim = {
       enable = true;
       settings = {
         formatters = {
@@ -25,7 +26,7 @@
         '';
       };
     };
-  programs.nixvim.userCommands = {
+    userCommands = {
       FormatDisable = {
         bang = true;
         desc = "Disable autoformat-on-save";
@@ -67,4 +68,5 @@
         range = true;
       };
     };
+  };
 }
```

Next, I need to install prettierd. The conform nixvim module doesn't install the configured tools so they need to be installed separately. I didn't install nixfmt because it was installed in `treefmt.nix`.

<!-- TODO Link to commit 34aa11a -->

And configure conform to use prettierd with markdown files:

<!-- TODO Link to commit 5209f56 -->

Run `:ConformInfo` in my neovim session editing this markdown file:

<!-- TODO Insert image 38-working_prettier_conform_info.png -->

Nice! Now what happens when I save the file? It changes things. Lots of things.

<!-- TODO Insert image 38-prettier_fixes_1.png -->

- Stripped any trailing whitespace I might have accidentally left. Cool.
- It modified the table header to be `| -- |` instead of `|----|`.
- It's changed any italics using `*word*` to `_word_`. Fair enough.
- But it's also applied the above to things that I didn't mean to be italics, like this:

<!-- TODO Insert image 38-prettier_fixes_2.png -->

I'll have to be careful about that. Fixed it by wrapping `ltex_plus` in backticks (as I should have originally done anyway).

I've got to admit, that was all way harder than I thought it would be and I've had enough for the time being. Hopefully the next lot of neovim changes won't be so punishing.

Done for now.

```bash
cd ~/code/nix/nix-config
git checkout main
git merge markdown-formatting
```

# References

- [neovim/nvim-lspconfig: Quickstart configs for Nvim LSP](https://github.com/neovim/nvim-lspconfig/)
- [dprint/dprint: Pluggable and configurable code formatting platform written in Rust.](https://github.com/dprint/dprint)
- [znck/grammarly: Grammarly for VS Code](https://github.com/znck/grammarly)
- [Automattic/harper: The Grammar Checker for Developers](https://github.com/automattic/harper)
- [ThePrimeagen/htmx-lsp: its so over](https://github.com/ThePrimeagen/htmx-lsp)
- [valentjn/ltex-ls: LTeX Language Server: LSP language server for LanguageTool :mag::heavy_check_mark: with support for LaTeX :mortar_board:, Markdown :pencil:, and others](https://github.com/valentjn/ltex-ls)
- [ltex-plus/ltex-ls-plus: LTeX+ Language Server: LSP language server for LanguageTool :mag::heavy_check_mark: with support for LaTeX :mortar_board:, Markdown :pencil:, and others](https://github.com/ltex-plus/ltex-ls-plus)
- [Feel-ix-343/markdown-oxide: Markdown Language Server](https://github.com/Feel-ix-343/markdown-oxide)
- [artempyanykh/marksman: Write Markdown with code assist and intelligence in the comfort of your favourite editor.](https://github.com/artempyanykh/marksman)
- [kitten/prosemd-lsp: An experimental proofreading and linting language server for markdown files ✍️](https://github.com/kitten/prosemd-lsp)
- [remarkjs/remark-language-server: A language server to lint and format markdown files with remark](https://github.com/remarkjs/remark-language-server)
- [remarkjs/remark: markdown processor powered by plugins part of the @unifiedjs collective](https://github.com/remarkjs/remark)
- [remark - markdown processor powered by plugins](https://remark.js.org/)
- [tailwindlabs/tailwindcss-intellisense: Intelligent Tailwind CSS tooling for Visual Studio Code](https://github.com/tailwindlabs/tailwindcss-intellisense)
- [Myriad-Dreamin/tinymist: Tinymist (ˈtaɪni mɪst) is an integrated language service for Typst (taɪpst).](https://github.com/Myriad-Dreamin/tinymist)
- [xna00/unocss-language-server](https://github.com/xna00/unocss-language-server)
- [errata-ai/vale-ls: :zap: An implementation of the Language Server Protocol (LSP) for the Vale command-line tool.](https://github.com/errata-ai/vale-ls)
- [errata-ai/vale: :pencil: A markup-aware linter for prose built with speed and extensibility in mind.](https://github.com/errata-ai/vale). Another prose/grammar checker. Worth checking out.
- [zk-org/zk: A plain text note-taking assistant](https://github.com/zk-org/zk)
- [stderr error .../vim/lsp/rpc.lua:677 (neovim) · Issue #236 · artempyanykh/marksman](https://github.com/artempyanykh/marksman/issues/236)
- [Prettier · Opinionated Code Formatter · Prettier](https://prettier.io/)
- [Language Server - Harper](https://writewithharper.com/docs/integrations/language-server#Supported-Languages)
- [LTeX – Grammar/Spell Checker Using LanguageTool with Support for LaTeX, Markdown, and Others | LTeX](https://valentjn.github.io/ltex/)
- [LTeX+ – Grammar/Spell Checker Using LanguageTool with Support for LaTeX, Markdown, and Others | LTeX+](https://ltex-plus.github.io/ltex-plus/)
- [nvim-neorg/neorg: Modernity meets insane extensibility. The future of organizing your life in Neovim.](https://github.com/nvim-neorg/neorg)
- [vale_ls - nixvim docs](https://nix-community.github.io/nixvim/plugins/lsp/servers/vale_ls/index.html)
- [.vale.ini - Vale CLI](https://vale.sh/docs/vale-ini)
- [Neovim - Harper](https://writewithharper.com/docs/integrations/neovim)
- [Rules - Harper](https://writewithharper.com/docs/rules)
- [dprint-plugin-markdown - MyNixOS](https://mynixos.com/nixpkgs/package/dprint-plugins.dprint-plugin-markdown)
