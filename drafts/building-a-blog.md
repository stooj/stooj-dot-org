Title: Building a blog
Date: 2024-08-26 12:33:07
Category: Meta

One of the most useful lessons I learned early in my career (I kind of wished
I'd learned it at school, that would have saved a lot of heartache) is to
document things. Document _everything_. At least, document _everything that you
want to do more than once_.

Here's the flow:

1. Figure out how to do something and write down your struggle.
2. Tear down whatever you did and try to reproduce it using your notes.
3. Use those notes to script the process using BASH.
4. Use the bash script to automate the process using... Ansible? Salt? Some
   other tool?

Fair enough, that process probably isn't going to work for learning to juggle,
but it _works wonders_ for anything to do with computers, which are one of my
favourite things.

This works great in theory, but I always get stuck with documentation in two
places:

1. Where to document?
2. How to document?

Question 1 is really about "who needs to read this nonsense?" If it's just me,
then as long as it's readable in a terminal then I'm golden (this is not
actually true, more on that later.)

If anyone else needs to read it, then it needs to be on a webpage somewhere. I'm
planning to finally solve this age-long question today.

Question 2 is much harder, and this post represents the start of my (hopefully
final) journey to solve it.

## 1. Where to document

- It's got to be on the web. I am lucky enough to have a wonderful partner and
  who shall be included in all things, but who spends far less of their day in a
  terminal, so would appreciate a nice web display.
- It's got to be decently viewable on a phone.

I have two categories of notes.

1. <del>insensitive</del> <del>unsensitive</del> <del>non-sensitive</del> huh. Ehm, not-secret things
   that can be on the public web.
2. Slightly sensitive things that need to be accessible via a website when
   connected to a VPN or something. I'll solve that part another day.

Let's deal with #1 today and make some (apparently without thinking, but I
promise I have reasons) choices:

1. Write notes in [Markdown](https://daringfireball.net/projects/markdown/)
2. Generate a site with [Pelican](https://getpelican.com/)
3. Deploy it with [Pulumi](https://www.pulumi.com/).
4. Host it on [Microsoft Azure](https://azure.microsoft.com/en-us).[^1]

Lets get started.

## Writing notes in Markdown

I'll tell you a secret: I _really don't like_ Markdown. It's fractured, the spec
is vague, unpredictable with indentation and is just not expressive enough for
me.

Take <del>definition</del> description lists: somehow I end up
using them all the time, especially when explaining command-line options or
vim-keybindings or the like. Markdown doesn't have them.

> But what about [GitHub Flavored Markdown](https://github.github.com/gfm/)?

Nope, doesn't support them.

> Yeah, but [Python-Markdown](https://python-markdown.github.io/extensions/definition_lists/) does.

You see the problem here? I'm going to need a disclaimer at the bottom of my
site:

> This site is created with GitLab Flavoured Markdown and should be generated
> with the comrak tool and the glfm gem. Also best viewed at 1024x768
> resolution.

Don't even get me started on [Slack's `mrkdwn` nonsense](https://slack.com/help/articles/202288908-Format-your-messages).

But it's **everywhere** (maybe because everyone can make up their own version of
it) so that's where I'm going to start. Hopefully in the future I'll have a
build-chain of:

```
something better → markdown → html
```

but right now, we're starting with Markdown.

<!-- TODO Insert hurray gif here. Monty Python minstrels? -->

Time to make a make a start. I'm going to make a directory and save this file
into it. I always have my version-controlled anything in a directory called
`code`, and I always have written version-controlled notes in a subdirectory
called `docs`. And this project (because it's my website) is going to be called
`stooj-dot-org`.

1. `mkdir --parents ~/code/docs/stooj-dot-org`
2. `cd ~/code/docs/stooj-dot-org`
3. `touch hello-world.md`

Right. We've got a directory. And we've got a file for me to write all this
stuff in. Now to get Python and Pelican up and running.

## Create a flake for a development environment

Wait, what? A flake? Whassat?

Here's the thing. I have migrated to NixOS nearly everywhere because it's
utterly wonderful (see the separate post that I'll write one day about why).

<!-- TODO: Write a blog post about the magic of NixOS -->

But I'm not actually that good at writing Nix yet, and haven't wrapped my head
around flakes; I just know enough to get by.

If you're not using Nix, then you can ignore this bit. If you **are** using Nix,
then you probably know more about it than I do and can also ignore this section.
See you in the next section.

If you're like me and are using NixOS, but don't actually know it that well yet,
and you're happy to have a flake that probably does things badly, then feel free
to follow along!

I'm also assuming you have flakes enabled and `nix-direnv` set up.

1. Create a python-dev-environment flake using a template from [flakehub's dev-templates](https://github.com/the-nix-way/dev-templates):

```bash
1. nix flake init --template "https://flakehub.com/f/the-nix-way/dev-templates/*#python"
```

2. Check the `.envrc` file to make sure it's safe: `cat .envrc`:

```bash
2. use flake
```

3. OK. It just uses the flake. Check the flake to make sure **it's** OK: `cat
flake.nix`

Aaah. Makes perfect sense.

There are plenty of better explanations of flakes out there, you should read
them to understand what's going on in this flake file.

I want to use [Poetry](https://python-poetry.org/) rather than pip for python
dependencies (it works way better with Pulumi).

Time to make some changes to the flake so poetry is installed as well. Change
the `packages` list of the `flake.nix` file to this by adding `poetry`:

```nix
        packages = with pkgs;
          [
            python311
            poetry
          ]
          ++ (with pkgs.python311Packages; [
            pip
            venvShellHook
          ]);
```

While we're there, I'm going to remove the minor-version pinning for python.

```nix
        packages = with pkgs;
          [
            python3
            poetry
          ]
          ++ (with pkgs.python3Packages; [
            pip
            venvShellHook
          ]);
```

Now, allow direnv to use the `.envrc` file: `direnv allow`. The flake should get
auto-loaded and you'll be dropped into a dev environment with `python` and
`poetry` installed!

## Installing pelican

Welcome back. If you missed it, we installed `python3` and `poetry` using some
weird not-really-installed-but-installed-in-this-directory magic while you were
gone. You should install poetry and python however you would like to.

Done it? Cool.

Now it's time to install Pelican.

First of all, initialize poetry in the directory:

```bash
poetry init
```

See? Time for a <dev>definition</dev> description list! This is the perfect
opportunity. I hope this works on whatever parser Pelican is going to use...

**\*Note:** If anything is in italics, then I used the default option.\*

Package name
: _stooj-dot-org_

Version
: _0.1.0_ [^2]

Description
: Stoo's site using lots of fancy cloud stuff

Author
: Stoo <i-will-think-of-an-email-later@stooj.org>

License
: GPL-3.0-or-later

Compatible Python versions
: ^3.11

Would you like to define your main dependencies interactively?
: no

Would you like to define your development dependencies interactively?
: no

Do you confirm generation
: _yes_

This is going to create `pyproject.toml`. I always add a little extra to the
bottom of my `pyproject.toml` file so that it matches the flake and my LSP works
correctly:

```toml
[tool.pyright]
venvPath = "."
venv = ".venv"
```

OK, time to install Pelican and the markdown dependency:

```bash
poetry add "pelican[markdown]"
```

Huh, neat. I didn't know about the square-bracket notation for marking
dependencies.

Run the `pelican-quickstart` tool. Time for another description list!!

Where do you want to create your new web site?
: site

What will be the title of this web site?
: Stoo Dot Org

Who will be the author of this web site
: Stoo

What will be the default language of this web site?
: _en_

Do you want to specify a URL prefix?
: n

Do you want to enable article pagination?
: _Y_

How many articles per page do you want?
: _10_

What is your time zone?
: Etc/UTC

Do you want to generate a tasks.py/Makefile to automate generation and publishing?
: _Y_

Do you want to upload your website using FTP?
: _N_[^3]

Do you want to upload your website using SSH?
: n

Do you want to upload your website using Dropbox?
: n

Do you want to upload your website using S3?
: y

What is the name of your S3 bucket?
: fixmeidontknowyet [^4]

Do you want to upload your website using Rackspace Cloud Files?
: n

Do you want to upload your website using GitHub Pages?
: n

Right, time to move this file (again) and turn it into a pelican-friendly entry.

1. Move the file: `mv hello-world.md site/content/`
2. Add the following to the top of `site/content/hello-world.md`:

```markdown
Title: Hello World
Date: 2024-08-26 12:33:07
Category: Meta
```

1. Change into the site directory: `cd site`
2. Generate the site locally: `pelican content`
3. Run the dev server so we can check it in a browser: `pelican --listen`
4. Go and have a look at http://127.0.0.1:8000 and see what it looks like. [^5]
5. Discover that python markdown **does** support description lists (:hurray:)
   but **doesn't** support `~~strikethrough~~` syntax by default. Be right back,
   [tpope/vim-surround](https://github.com/tpope/vim-surround) to the rescue again!

## Theming Pelican

![top of hello-world blog post with default theme enabled](images/building-a-blog/default-theme.png)

The default pelican theme is a little _notmystyle_, so let's change it to something
else.

There's a gallery of existing themes over at [pelicanthemes.com](http://www.pelicanthemes.com).

The workflow is "download the theme and save it somewhere, then update your
pelican config". That's going to need to be included as part of the CI/CD step
in the future, but for now we're following the README!

1. Get back to your home directory: `cd`
2. Clone the pelican-themes repo: `git clone --recursive https://github.com/getpelican/pelican-themes ~/pelican-themes`
3. Get back to the pelican project directory: `cd ~/code/docs/stooj-dot-org/site`
4. Install the theme: `pelican-themes --install ~/pelican-themes/cebong --verbose`

Huh, so that copies the theme into the virtualenv. It's an unusual approach,
because the venv is sorta stateful now, you can't just delete it whenever you
like. I can live with that though!

Last thing, add `THEME=cebong` to the `pelicanconfig.py` file and then rerun the
build and serve command:

```bash
pelican content && pelican --listen
```

![top of hello-world blog post with cebong theme enabled](images/building-a-blog/cebong-theme.png)

Hmm, code blocks are broken.

![screenshot of broken code sample](images/building-a-blog/cebong-code-block.png)

Time to try a different theme:

```bash
sed -i 's/cebong/graymill/' pelicanconf.py
pelican-themes --install ~/pelican-themes/graymill --verbose
```

Regenerate the site and run the server

```bash
pelican content && pelican --listen
```

![top of hello-world blog post with graymill theme enabled](images/building-a-blog/graymill-theme.png)

Oooh, that's kinda lovely. I might need to get my magnifying glass to actually
read it, but I'm sure the text is working great!

Where's the syntax highlighting though? 🤔

Ugh, these themes haven't been touched in years, and that's two themes that are
broken. And [cebong's production site](http://kecebongsoft.com) and
[graymill's production site](https://muchbits.com) both 404.

[Hugo](https://gohugo.io/) is looking pretty nice right now.

[^1]:
    Wait, what? I will explain in a future note. Hopefully when I do, I will
    remember to come back here and add a link.

[^2]: I'll figure out actual proper versioning later (soon™).
[^3]: What is this, the 1990s??
[^4]: Pulumi is going to make the bucket, so we don't know what it'll be called yet.
[^5]: Can you even link to localhost? Guess we'll find out

# TODO Text

Now we turn it into a repository and host it on GitHub.
Disclaimer: I'd prefer not to use GitHub, but that's the happy-path for pulumi
deployments just now. Hopefully your-amazing-vcs-platform will be supported in
the future.

## Deploying with Pulumi

Disclaimer: I work for Pulumi. So I already have a Pulumi account set up and use
Pulumi Cloud. I'd recommend it even if they didn't employ me, but I would say
that, wouldn't I? They have a pretty amazing [free tier](https://www.pulumi.com/pricing/) so I'd say it's worth a look.

Totally out of character, I'm going to use the web UI to get this all started.
The goal will be to have a blog that I can write and publish with _nothing_
locally installed apart from **vim** and **git**. Nothing else.

1. Log into [app.pulumi.com](https://app.pulumi.com/).
2. Choose your organization if you're fancy and have multiple organizations.
   ![screenshot of organizations dropdown](images/building-a-blog/organizations.png)
3. Click on `New Project`
4. Choose `Azure` from the `Choose your cloud` dropdown.
5. Search for `Static Website` and pick the one in the language of your choice.
   I'm not planning on doing anything fancy with the pulumi code, but might as
   well pick a language that I like. I'm choosing Go, because I can't bring
   myself to say that "I'm going with Go".
6. Click `Next`

### A side-quest: The GitHub app

You probably can't select `Pulumi Deployments` yet because Pulumi uses a
`GitHub` app and it's probably not installed yet.

1. Scroll to the bottom of the screen and select `Install GitHub App`

## Deploying with Pulumi again

No matter what I end up with, my partner will need to see it.

At one of my early jobs, we documented all our server configurations by writing
HTML. Here's a (made up) sample of what that looked like:

```html
<h2>2010-05-17</h2>
<p>Added new intranet site: <code>intra.example.com</code> to Apache sites.</p>
<p>All following commands were run on <code>webhost</code>.</p>
<ol>
  <li>
    Pulled new site from dev environment:
    <code>scp -r devserver:working/newsite ~/</code>
  </li>
  <li>
    Copied files to correct directory: <code>sudo mv newsite /var/www/</code>
  </li>
  <li>
    Fixed permissions:
    <code>sudo chown -r www-user:www-user /var/www/newsite</code>
  </li>
  <li>.... etc etc.</li>
</ol>
```

Not recommended.

> Hey team! Has anyone heard of Pandoc? And Markdown?
> No? This is going to blow your minds.

And thus began my quest to solve question

Things to fix:

- Pulumi org name needs to match GitHub org name
- `higara` has already been taken on GitHub :(
- OIDC for Azure
- Create a GitHub org, or use `stooj` single-user org?
