Title: Converting to HTML
Date: 2025-05-17T21:25:37
Category: NixOS

> !Warning
> This post contains swearies

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

```bash
which lith
```

```
/nix/store/sm7737ch8s1sn2g1m3gbsgrqp0kd3kmf-norgolith-0.2.0/bin/lith
```

OK, it's a small win but I'm pretty chuffed that that error didn't take me four hours to sort.

I'll run through the first-site tutorial first to figure out the basics.

## Norgolith first site

I'm just running through the [Getting started Guide](https://ntbbloodbath.github.io/norgolith/docs/getting-started/) so I'll keep the chatter to a minimal.

I **will** actually commit things as I go though. I get really mad trying to follow other folks blogs when they don't show the diffs after running stuff, because I'm probably using a different version and it'll generate something different and my replication ends up failing because I can't see what's happening because you said "just run this" without showing me the result. This annoying behaviour is a big inspiration for this blog and it's (frankly) daft adherence to tiny git commits for every bit of trivia.

```bash
lith init mysite
```

I just chose the defaults for now.

<!-- TODO turn this into a definition list somehow -->

- `Site URL: http://localhost:3030`
- `Site URL: en-US`
- `Site title: mysite`

```
10:45 PM 2025-05-17  INFO init: Initializing new Norgoliht site: mysite
> Site URL: http://localhost:3030
> Site language: en-US
> Site title: mysite
10:46 PM 2025-05-17  INFO init: Created site directories
10:46 PM 2025-05-17  INFO init: Created norgolith.toml
10:46 PM 2025-05-17  INFO init: Created index.norg
10:46 PM 2025-05-17  INFO init: Created HTML templates
10:46 PM 2025-05-17  INFO init: Created RSS template
10:46 PM 2025-05-17  INFO init: Created assets
10:46 PM 2025-05-17  INFO init: Congratulations, your new Norgolith site was created in /home/stooj/code/docs/stooj-dot-org/mysite

Your new site structure:
┌───────────┬────────────────────────────────────┐
│ Directory │ Description                        │
╞═══════════╪════════════════════════════════════╡
│ content   │ Norg site content files            │
├───────────┼────────────────────────────────────┤
│ templates │ HTML templates                     │
├───────────┼────────────────────────────────────┤
│ assets    │ Site assets (JS, CSS, images, etc) │
├───────────┼────────────────────────────────────┤
│ theme     │ Site theme files                   │
├───────────┼────────────────────────────────────┤
│ public    │ Production artifacts               │
├───────────┼────────────────────────────────────┤
│ .build    │ Dev server artifacts               │
└───────────┴────────────────────────────────────┘

Please make sure to read the documentation at https://ntbbloodbath.github.io/norgolith
```

And here's what it generated:

<!-- TODO Link to commit fad67b9 -->

There's a "Tip":

> You might want to add `.build` directory to your `gitignore`.

Done.

<!-- TODO Link to commit ad7fd35 -->

What's next? Create a new post. Oooh, it has a special command for creating norg files, that might be annoying. I kinda want to treat this as a regular Neorg workspace, I don't want to have a separate process for _this_ workspace.

Stop complaining, it's just the tutorial. It maybe doesn't mean you _have_ to do it, maybe it just ensures the metadata is set correctly or something.

```bash
lith new first-post.norg
```

```
10:54 PM 2025-05-17 ERROR Unable to create site asset: not in a Norgolith site directory
```

OK, I guess I need to be in the right directory now

```bash
cd mysite
lith new first-post
```

I'm just choosing the defaults again.

<!-- TODO another description list please -->

- `Title: First Post`
- `Description: `
- `Author(s): stooj`
- `Categories: `
- `Layout: default`

```
> Title: First Post
> Description:
> Author(s): stooj
> Categories:
> Layout: default
10:57 PM 2025-05-17  INFO new: Created norg document: /home/stooj/code/docs/stooj-dot-org/mysite/content/first-post.norg
```

<!-- TODO Link to commit 7d9e730 -->

Seems to be a pretty standard `norg` file. There's `draft: true` in the metadata, just like every post I've written so far 😀.

Let's see what it looks like:

```bash
lith serve --open
```

```
11:00 PM 2025-05-17  INFO serve: Starting development server...
Server started in 30ms
• Local:   http://localhost:3030/
• Network: use --host to expose

11:00 PM 2025-05-17  INFO serve: Opening the development server page using your browser ...
11:00 PM 2025-05-17  INFO serve: GET / => 200 OK in 3.2ms
11:00 PM 2025-05-17  INFO serve: GET /assets/norgolith.svg => 200 OK in 64.6µs
11:00 PM 2025-05-17  INFO serve: GET /assets/style.css => 200 OK in 150.4µs
11:00 PM 2025-05-17  INFO serve: GET /assets/norgolith.svg => 200 OK in 372.6µs
```

<!-- TODO Insert image 45-first_run_of_norgolith.png -->

Uhm, nice. But that's not my first post. Ooh, it's not listed on the index (which is `content/index.norg`) but it's at [localhost:3030/first-post](http://localhost:3030/first-post)

How does it look with elinks?

<!-- TODO Insert image 45-first_post_in_elinks.png -->

Pretty garbage actually. I think that's my default configuration of elinks though rather than the site's fault.

Next I've to change the draft metadata to false and build the site:

<!-- TODO Link to commit 70249c1 -->

Building the site with:

```bash
lith build --minify
```

Nice, there's a bunch of html in the `public` directory. That'll be ignored in future but committing just now for the sake of anyone following along at home.

<!-- TODO Link to commit 94e48d4 -->

OK, what does it look like with some more norg-specific markdown? Here's a document I prepared earlier...

<!-- TODO Link to commit 3e11b77 -->

The only two extra metadata fields are `draft` and `layout`.

But that actually kinda looks garbage.

<!-- TODO Insert image 45-first_post_with_norg_content.png -->

Huh, that's disappointing. Why is there no styling? No list markers? No differentiation between headings? TODO items? My lovely concealer icons?

The `index.norg` page has piles of extra crap; do I need that everywhere or is the default theme very basic and so the `index.norg` has a bunch of extra stuff to make it "theme-agnostic"?

Here's a clue from [the docs](https://ntbbloodbath.github.io/norgolith/docs/commands/#Theme-Management):

```bash
lith theme info
```

```
09:05 AM 2025-05-18 ERROR Could not display the theme info: there is no theme installed
```

That probably has something to do with it 😁

Looking through `style.css` <!-- TODO add link to style.css file --> it looks like there isn't any styling for much at all, and the base layer is setting font sizes to inherit (does that mean they all become the same size? I haven't written css for 10 years).

<!-- TODO Insert image 45-first_post_dev_tools.png -->

Oh, did I mention qutebrowser has devtools? 🥰

OK, so maybe I need to make my own theme. I've been inspired by many many web designs since my first website in the Compuserve days, but my biggest inspiration at the moment is this glorious series of websites:

- [Motherfucking Website](http://motherfuckingwebsite.com/).
- [Better Motherfucking Website](http://bettermotherfuckingwebsite.com/)
- [The Best Motherfucking Website](https://thebestmotherfucking.website/)

They are all glorious. Actually, my end-goal is something like [the monospace web](https://owickstrom.github.io/the-monospace-web/), [Johnny Decimal](https://johnnydecimal.com/) or even [aviskarse's blog](https://www.aviskase.com/). I love the simple tree look and hopefully it won't be a nightmare to code.

In my brain, a `Theme` and a `Template` need to be adjusted in parallel, but norgolith's docs talk about distributing themes without mentioning including templates in them (and the [example theme 404s](https://github.com/NTBBloodbath/norgolith-pico-theme) 🙁). Is the theory "all themes expect a set of classes to be present in the templates"? You can tell I've not done frontend stuff for years, huh?

Looking at the pre-generated templates, the body and footer have some pre-defined classes but it's pretty minimal.

OK, I'm going to strip everything out until I get a motherfucking website and then build from there, learning as I go.

I do _want_ syntax highlighting for code samples, but step one is to get a zero-js site.

<!-- TODO Link to commit 9b31606 -->

I don't know what Tailwind is. Get rid of it.

<!-- TODO Link to commit 0d819d9 -->

I don't want my own css file either just now. Out it goes.

<!-- TODO Link to commit 8c00dbb -->

That's looking much better already! Loving the live-reload.

<!-- TODO Insert image 45-first_post_bare_html.png -->

But if I'm going to seriously consider making my own theme and start writing html templates and stuff, I need editor support for that.

Time to revisit my neovim configuration.

TODO: Install linters and LSPs for html/css/javascript?

# References

- [Welcome To Norgolith - Norgolith](https://ntbbloodbath.github.io/norgolith/)
- [Installation - Norgolith](https://ntbbloodbath.github.io/norgolith/docs/installation/)
- [Getting Started - Norgolith](https://ntbbloodbath.github.io/norgolith/docs/getting-started/)
- [Commands Reference - Norgolith](https://ntbbloodbath.github.io/norgolith/docs/commands/#Theme-Management)
- [Motherfucking Website](http://motherfuckingwebsite.com/)
- [Better Motherfucking Website](http://bettermotherfuckingwebsite.com/)
- [The Best Motherfucking Website](https://thebestmotherfucking.website/)
- [The Monospace Web](https://owickstrom.github.io/the-monospace-web/)
- [A system to organise your life • Johnny.Decimal](https://johnnydecimal.com/)
- [aviskase](https://www.aviskase.com/)
