Title: A slighly improved local site
Date: 2025-05-25T20:56:57
Category: NixOS

> !Warning
> This post also contains swearies

Well, here we are again. Where was I?

Oh yeah, I was taking a perfect website to a better perfect website with the addition of a css file. Here it is:

<!-- TODO Link to commit 6053004 -->

Now that I've got a formatter, here's what the formatter did to `templates/base.html`. There's no actual changes here, just a bunch of whitespace fixes. Actually, I'll just open **all** the files in `templates` and let my formatter do it's work

<!-- TODO Link to commit 9281df3 -->

Right, add that stylesheet into the `base` template:

<!-- TODO Link to commit 1d51d3d -->

I was a bit stumped about why `djlint` was telling me not to use entity references (`&copy;` in this case). According to the [Google HTML/CSS Style Guide](https://google.github.io/styleguide/htmlcssguide.html#Entity_References) it's because in a UTF-8 world they're not needed any more. Neat!

<!-- TODO Link to commit c8a43d8 -->

Speaking of, that copyright line doesn't really suit me because presumably my words aren't copyright of [NTBBloodbath](https://github.com/NTBBloodbath), so I'm just going to comment them out for now until I decide on:

- a license
- a permanent home for the source

<!-- TODO Link to commit ad0e981 -->

Despite what the perfect and better perfect websites say, I like a picture now and then. Currently my system sucks: "here's a big markdown file and here's a completely separate image". I'm probably not going to chuck all these binary objects into git, but I do want the source code to encompass as much semantic meaning as possible.

What do I mean by that? I don't really know. Let's try something cool though. Images in neovim.

<!-- TODO Link to commit d8079df -->

That throws an error when I re-open vim:

```
image.nvim: magick rock not found, please install it and restart your editor. Error: "...ajit2.1-magick-
1.6.0-1/share/lua/5.1/magick/wand/lib.lua:206: /nix/store/w47x7y9xjgq7n3171ckg722ddwf2pi3v-gcc-13.3.0-li
b/lib/libstdc++.so.6: version `CXXABI_1.3.15' not found (required by /nix/store/493cqjb6a125c5wkpsvgg23n
5g48sm0f-djvulibre-3.5.28-lib/lib/libdjvulibre.so.21)"
```

<!-- TODO Link to commit 58c59db -->

Hmm. Still throws that error.

Oooh, checking the docs you also need a lua package.

<!-- TODO Link to commit 19ecb53 -->

Will that work? Uhm. It built at least which I didn't expect. Still didn't fix the error though.

What if I add imagemagick as a regular package?

<!-- TODO Link to commit 623e2dc -->

Nope.

Maybe I need to set the backend? Make some room first:

<!-- TODO Link to commit 32b2401 -->

And set the backend to "kitty":

<!-- TODO Link to commit 5a13edf -->

Nope. Manually configure the processor ("magick_cli" should be the default though):

<!-- TODO Link to commit c01568f -->

OK, time to test a minimal configuration to check that nothing else is interfering with `image.nivm`:

<!-- TODO Link to commit c3375c9 -->

> !NOTE
> I added `relativenumber` in there as an easy way to check that I'm definitely in the `nixvim`-configured neovim environment.

Huh, no error there. And does it work?

`test.md`:

```markdown
# Hello world

![test image](./assets/norgolith.svg)
```

<!-- TODO Insert image 49-image_working_with_empty_config.png -->

Hey! It works. So there is something funky with my configuration that's breaking `image.nvim`. Time to start adding things back in and see when it breaks.

I'll move the same minimal `image.nvim` config back into it's correct place, and pull in my general `settings.nix` file.

<!-- TODO Link to commit f7bf48a -->

OK, that's working. How about my most troublesome and beloved plugin, `neorg`?

<!-- TODO Link to commit dd586c0 -->

That threw a different error because no treesitter. Revert `dd586c0` and enable `nvim-treesitter`.

```bash
git revert dd586c0
```

<!-- TODO Link to commit fae49be -->

<!-- TODO Link to commit 0ba5db2 -->

And better enable `cmp` as well, I think neorg will get mad about that otherwise:

<!-- TODO Link to commit 75628dc -->

And reenable `neorg` again.

<!-- TODO Link to commit ef5d955 -->

No errors, image is still showing (how cool is that, by the way?).

I'm not going to re-enable every file one-by-one. I thought neorg would be the most likely culprit, but it's time to binary-search this problem (kind of):

<!-- TODO Link to commit 9c0d781 -->

Still working, and it looks kinda awesome now 😊.

<!-- TODO Link to commit d1ca009 -->

Still working. Hmm. It's either the LSPs or it's going to just _magically_ work now.

<!-- TODO Link to commit 3b4fb6d -->

It just works. Maybe it was a caching issue?

Oooh. Nope. I'm still getting the same error, but only if I open a neorg file. I _wonder_...

<!-- TODO Link to commit e9ac021 -->

Nope, same error. OK, so neorg was the cause?

<!-- TODO Link to commit 04e666e -->

If I turn neorg _off_, images work:

<!-- TODO Insert image 49-image_working_with_disabled_neorg.png -->

If I turn it _on_, images don't work (`magick not found`).

<!-- TODO Insert image 49-image_not_working_with_enabled_neorg.png -->

Opened a bug: [(BUG) Neorg plugin breaks Image plugin for norg files. · Issue #3399 · nix-community/nixvim](https://github.com/nix-community/nixvim/issues/3399)

And disable image until it's fixed.

<!-- TODO Link to commit b2af25d -->

Well, that was a bit of a tangent that didn't go anywhere. Shame really.

I'm bored of documentation stuff for now, it's time to do something else. Since my branch just has a bunch of disabled code I **should** just delete it, but then this blog post woudn't have any commits to link to. So I'm merging it as normal.

```bash
cd ~/code/nix/nix-config
git checkout main
git merge neorg-images
```

# References

- [Google HTML/CSS Style Guide](https://google.github.io/styleguide/htmlcssguide.html#Entity_References)
- [3rd/image.nvim: 🖼️ Bringing images to Neovim.](https://github.com/3rd/image.nvim)
