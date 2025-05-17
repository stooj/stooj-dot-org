Title: Converting to HTML
Date: 2025-05-17T21:25:37
Category: NixOS

I've been agonizing for ages about which static site generator I'm going to choose. Should I go for the "standard" and choose Hugo? Should I respect my roots and pick Pelican? Maybe today is the day I should learn Jekyll, like my father before me and his father before him? What's Jamstack? Astro seems fun, but a bit more work than I'm looking for. Eleventy seems to me like the next big thing.

And then I discovered [Norgolith](https://ntbbloodbath.github.io/norgolith/). A static site generator that converts neorg directly to html? Go on...

- Write in Norg, publish in HTML? 😎
- Real-time html preview? 🫢
- Validation engine? Probably going to be important for me.
- Something about theming being easy. I will believe _that_ when I see it.

Because you are living in the future, you might know if this experiment was successful or not, because the plain text version of this blog will all be written in glorious neorg instead of markdown. If it's still in Markdown, then this experiment is destined to fail. All I can do is try.

Of course, if this **does** work I'll have to convert ever piece of markdown in this repo with the neorg equivalent, that'll be an interesting wee challenge.

And I've got all these TODOs everywhere; that should eventually embed the commit diff pulled from GitHub or whatever. Can I do that with Norgolith? No idea. It's got a "Plugin-ready architecture" though, so I might be learning Rust earlier than I thought.

One sign that this project rocks is that the installation instructions has two installation methods, and one of them is using a Nix Flake. That'll do very nicely thank you. I spent all of the last post setting up direnv and stuff so I can install norgolith locally for this project.

I've been very strict about my commits to the `nix-config` and `higara` repos, and a lazy bum about commits to this repo. Since the real work is happening here for this project I need to be stricter.

Starting now.

Actually, stuff that. I'm going to commit changes to this markdown file as I go, but I'm not going to bother embedding them in the post. Why would anyone want to see a second plain-text copy of the stuff they've just read?

I don't know what I'll need yet so I'm going to start with another blank flake and build it up as needed.

```bash
nix flake init -t templates#empty
```

<!-- TODO Link to commit da58f0a -->

I'm going to build the flake line by line like I did last time, but maybe I should do the `.envrc` file first so I'm "auto-testing" my syntax as I go.

<!-- TODO Link to commit e338903 -->

And tell direnv that it's OK, I trust this file:

```bash
direnv allow
```

Ooh! Error messages. An empty flake doesn't work, good to know.

```
direnv: loading ~/code/docs/stooj-dot-org/.envrc
direnv: using flake
error: flake 'git+file:///home/stooj/code/docs/stooj-dot-org' does not provide attribute 'devShells.x86_64-linux.default', 'devShell.x86_64-linux', 'packages.x86_64-linux.default' or 'defaultPackage.x86_64-linux'
direnv: nix-direnv: Evaluating current devShell failed. Falling back to previous environment!
direnv: export +NIX_DIRENV_DID_FALLBACK ~PATH
```

The `.direnv` directory needs to be ignored. I really should ignore that in my global `~/.config/git/ignore` or something but that's bitten me in the past so I like to explicitly ignore things in their repos.

> I was working with a team who hadn't used git a lot before, so they didn't know to ignore stuff and commited things to the repo that shouldn't have been commited.
> If I had explicitly ignored those files in the `.gitignore` for the repo it wouldn't have been a problem.

<!-- TODO Link to commit 5bc5b07 -->

Back to the flake. Add a description:

<!-- TODO Link to commit 892f1bf -->

It's still broken. Yep, I know.

Nixpkgs input so we can reference and install things in the flake. Unstable again!

<!-- TODO Link to commit b3acc73 -->

Because the flake is automatically running every time the `flake.nix` file changes, the lock file was automatically created after I added `nixpkgs`. Here it is:

<!-- TODO Link to commit 2c21827 -->

Add flake-utils again:

<!-- TODO Link to commit 95f6ecf -->

And the updated `flake.lock` file that gets automatically adjusted:

<!-- TODO Link to commit ff7d40d -->

And finally the commit that will stop all the moaning and errors.

<!-- TODO Link to commit b40837d -->

That's better. Phew.

We need norgolith as an input as well.

<!-- TODO Link to commit d9d7e31 -->

And another auto-update to the `flake.lock` file:

<!-- TODO Link to commit e6e3705 -->

I wonder if I can do the same iteration thing with the `norgolith` input as I did with `nixpkgs`?

<!-- TODO Link to commit ea30a85 -->

Nothing exploded. That seems promising.

Finally I can try to install norgolith.

<!-- TODO Link to commit 7481f9c -->

Ahh! It did explode, it was just delayed.

```
error: infinite recursion encountered
```

That's fair. I should have said `norgolith = norgolith.stuff`.

<!-- TODO Link to commit c1dcd22 -->

Woah. Am I starting to get the hang of this? I fixed in one go!

# References

- [Welcome To Norgolith - Norgolith](https://ntbbloodbath.github.io/norgolith/)
- [Installation - Norgolith](https://ntbbloodbath.github.io/norgolith/docs/installation/)
