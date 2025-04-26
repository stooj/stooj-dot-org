Title: Nix Code Formatting
Date: 2025-04-26T16:19:45
Category: NixOS

So far I've written all my nix files without any help from lsps or formatters, so there's going to be a lot of fixes to do in every file.

Those changes aren't really meaningful though, every file is going to be modified with extra line braks or wrapping or indentation fixes.

1. No one cares about those commits
2. I can't be bothered going through every file, letting conform-nvim do it's thing, and committing the changes.

If only there was a way of configuring a project-wide formatter for nix. Well, of course there is obviously. It's called `nix fmt`, and [according to the docs](https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-fmt.html) there are three popular formatters:

1. [nixpkgs-fmt](https://github.com/nix-community/nixpkgs-fmt) - which is deprecated
2. [nixfmt](https://github.com/NixOS/nixfmt) - which replaced `nixpkgs-fmt` and maybe familiar as the package I've asked `conform-nvim` to use when I save nix files.
3. [alejandra](https://github.com/kamadorueda/alejandra) - for people with _real_ opinions about nix formatting.

I don't know enough about nix to have my own opinions about it yet, and `nixfmt` has been accepted as the standard in `nixpkgs` so that feels like the obvious choice.

Except the `fmt` in `nixfmt` **isn't** the style that is the official one accepted in [RFC-166(https://github.com/NixOS/rfcs/pull/166). :oof:

Anyway, according to the [README](https://github.com/NixOS/nixfmt?tab=readme-ov-file#nix-fmt) I can add it to my flake like so:

> !NOTE
> I disabled the formatter here using `:FormatDisable` because I'm wanting to use a different formatter now :facepalm:

<!-- TODO Link to commit 92d3e62 -->

Now I'm going to try to format my code in a single go:

```bash
cd ~/code/nix/nix-config
nix fmt
```

```
Passing directories or non-Nix files (such as ".") is deprecated and will be unsupported soon, please use https://treefmt.com/ instead, e.g. via https://github.com/numtide/treefmt-nix
```

Huh, OK. I will look into that. In the meantime, that worked. Big commit incoming:

```bash
git status
```

```
On branch nix-code-formatting
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   configuration.nix
	modified:   disks.nix
	modified:   flake.nix
	modified:   fonts.nix
	modified:   hardware-configuration.nix
	modified:   home/common/flameshot.nix
	modified:   home/common/gpg.nix
	modified:   home/common/nextcloud.nix
	modified:   home/common/ripgrep.nix
	modified:   home/common/sops.nix
	modified:   home/common/xdg.nix
	modified:   home/pindy/konsole.nix
	modified:   home/pindy/preferences.nix
	modified:   home/stooj/i3wm/i3.nix
	modified:   home/stooj/kitty.nix
	modified:   home/stooj/neovim/default.nix
	modified:   home/stooj/neovim/indent.nix
	modified:   home/stooj/neovim/keymaps.nix
	modified:   home/stooj/neovim/plugins/completion/cmp.nix
	modified:   home/stooj/neovim/plugins/editor/treesitter.nix
	modified:   home/stooj/neovim/plugins/lsp/conform.nix
	modified:   home/stooj/neovim/plugins/lsp/fidget.nix
	modified:   home/stooj/neovim/plugins/lsp/lsp.nix
	modified:   home/stooj/neovim/plugins/snippets/luasnip.nix
	modified:   home/stooj/neovim/plugins/utils/lastplace.nix
	modified:   home/stooj/neovim/plugins/utils/mini.nix
	modified:   home/stooj/neovim/plugins/utils/telescope.nix
	modified:   home/stooj/neovim/plugins/utils/which-key.nix
	modified:   home/stooj/neovim/search.nix
	modified:   home/stooj/neovim/settings.nix
	modified:   home/stooj/neovim/style/icons.nix
	modified:   home/stooj/neovim/style/theme.nix
	modified:   home/stooj/preferences.nix
	modified:   home/stooj/qutebrowser.nix
	modified:   power-management.nix
	modified:   vim.nix
	modified:   wireless.nix

no changes added to commit (use "git add" and/or "git commit -a")
```

A sample diff:

```diff

diff --git a/home/stooj/neovim/plugins/lsp/conform.nix b/home/stooj/neovim/plugins/lsp/conform.nix
index 6658aaa..d6f477c 100644
--- a/home/stooj/neovim/plugins/lsp/conform.nix
+++ b/home/stooj/neovim/plugins/lsp/conform.nix
@@ -1,12 +1,19 @@
-{ pkgs, lib, ... }: {
+{ pkgs, lib, ... }:
+{
   # conform.nvim
   # Lightweight yet powerful formatter plugin for Neovim
   # See https://github.com/stevearc/conform.nvim
   programs.nixvim.plugins.conform-nvim = {
     enable = true;
     settings = {
-      formatters = { nixfmt = { command = "${lib.getExe pkgs.nixfmt}"; }; };
-      formatters_by_ft = { nix = [ "nixfmt" ]; };
+      formatters = {
+        nixfmt = {
+          command = "${lib.getExe pkgs.nixfmt}";
+        };
+      };
+      formatters_by_ft = {
+        nix = [ "nixfmt" ];
+      };
       format_on_save = ''
         function(bufnr)
           -- Disable with a global or buffer-local variable
```

Huh, and that file _has_ already been formatted by nixfmt.

Commit all these changes first.

<!-- TODO Link to commit 379f50a -->

And change the formatter (disable conform again, isn't that command handy?):

<!-- TODO Link to commit b6f6fdd -->

Now, I should be able to open any existing file in the repo, save it and there won't be **any** diff because conform is using the same tool as `nix fmt` 🤞

Yup! That's working great, and our nix files are correctly formatted.

So what's treefmt?

It's kinda conform outside of vim; a single command to format all code in a directory using sensible defaults maintained by the community. That sounds fecking brilliant to me.

First I need to add it to my flake inputs:

<!-- TODO Link to commit 93940ee -->

Then I need to update the flake (I should do this more often)

```bash
nix flake update
```

<!-- TODO Link to commit 9b80159 -->

[The docs](https://github.com/numtide/treefmt-nix?search=1#flakes) have a pretty good improvement to the flake generally, so I'm going to break this into the smallest chunks possible.

Add treefmt as an output:

<!-- TODO Link to commit c0d3609 -->

Currently my formatter is hard-coded to only run on x86_64-linux, which is... well, fair enough for just me. But I should make that more generic.

The treefmt docs have a helper tool in the [README](https://github.com/numtide/treefmt-nix?search=1#flakes) that loops over **all** systems and generates an entry for each one. 

<!-- TODO Link to commit 438e636 -->

Wait, what's this `systems` thing? Ooh, treefmt is a project by numtide, so it'll be [this](https://github.com/nix-systems/nix-systems).

Because I've changed the flake's inputs, need to `nix flake update` again:

<!-- TODO Link to commit a770293 -->

Now to swap out nixfmt (rfc style) for treefmt.

<!-- TODO Link to commit ee2192e -->

This won't work though because I haven't _written_ `treefmt.nix` yet. Time to fix that.

<!-- TODO Link to commit eb64a60 -->

And try to format again and see what happens:

```bash
nix fmt
```

```
evaluation warning:  nixfmt-rfc-style is now the default for the 'nixfmt' formatter.
                    'nixfmt-rfc-style' is deprecated and will be removed in the future.
2025/04/26 17:51:29 INFO using config file: /nix/store/33nxdan6inyy96y6pqrrb14xq78bk8bs-treefmt.toml
WARN no formatter for path: .sops.yaml
WARN no formatter for path: README.md
WARN no formatter for path: home/pindy/secrets.yaml
WARN no formatter for path: home/stooj/neovim/files/snippets/markdown.lua
WARN no formatter for path: home/stooj/secrets.yaml
WARN no formatter for path: keys/pindy.asc
WARN no formatter for path: keys/stooj.asc
WARN no formatter for path: secrets.yaml
traversed 66 files
emitted 57 files for processing
formatted 57 files (0 changed) in 122ms
```

Haha! `rfc-style` is deprecated? Och dearie me.

<!-- TODO Link to commit 4058920 -->

So, running again shouldn't make any difference if nixfmt and nixfmt-rfc-style is the same?

```bash
nix fmt
```

```
2025/04/26 17:53:52 INFO using config file: /nix/store/las55dvgqw7rriwxas43vhjv3y1kfg2h-treefmt.toml
WARN no formatter for path: .sops.yaml
WARN no formatter for path: README.md
WARN no formatter for path: home/pindy/secrets.yaml
WARN no formatter for path: home/stooj/neovim/files/snippets/markdown.lua
WARN no formatter for path: home/stooj/secrets.yaml
WARN no formatter for path: keys/pindy.asc
WARN no formatter for path: keys/stooj.asc
WARN no formatter for path: secrets.yaml
traversed 66 files
emitted 57 files for processing
formatted 57 files (0 changed) in 108ms
```

Apparently. 0 changed files. But... but... conform was _definitely_ formatting things differently, right?

<!-- TODO Link to commit f92d999 -->

When I rebuld the system configuration with this, I get:

```
evaluation warning: nixfmt was renamed to nixfmt-classic. The nixfmt attribute may be used for the new RFC 166-style formatter in the future, which is currently available as nixfmt-rfc-style
```

Ugh. So treefmt is using `nixfmt`, which is the new nixfmt matching nixfmt-rfc-style, but conform is using `nixfmt`, which is the old nixfmt that doesn't match nixfmt-rfc-style. Oof.

So reverting

```bash
git revert f92d999
```

<!-- TODO Link to commit 3f2e076 -->

Presumably I'll start to get a warning when nixfmt-rfc-style needs to be renamed to nixfmt. [NixOS 25.05](https://github.com/NixOS/nixpkgs/issues/390768) is due next month 🎉

That'll do for now though, mission accomplished. All my code is formatted according to a single style and it's the official style.

```bash
cd code/nix/nix-config
git checkout main
git merge nix-code-formatting
```

# References


- [nix-community/nixpkgs-fmt: Nix code formatter for nixpkgs (maintainer=@zimbatm)](https://github.com/nix-community/nixpkgs-fmt)
- [NixOS/nixfmt: The official (but not yet stable) formatter for Nix code](https://github.com/NixOS/nixfmt)
- [kamadorueda/alejandra: The Uncompromising Nix Code Formatter](https://github.com/kamadorueda/alejandra)
- [Overview of Nix Formatters Ecosystem](https://drakerossman.com/blog/overview-of-nix-formatters-ecosystem)
- [Treefmt](https://treefmt.com/latest/)
- [treefmt-nix/ at main · numtide/treefmt-nix](https://github.com/numtide/treefmt-nix?search=1#flakes)
- [nix-systems/nix-systems: Externally extensible flake systems](https://github.com/nix-systems/nix-systems)
- [Configure - Treefmt](https://treefmt.com/latest/getting-started/configure/)
- [NixOS 25.05 – Release schedule · Issue #390768 · NixOS/nixpkgs](https://github.com/NixOS/nixpkgs/issues/390768)
