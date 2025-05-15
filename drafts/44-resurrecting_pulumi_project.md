Title: Resurrecting the Pulumi Project
Date: 2025-05-10
Category: Pulumi

It's time to think about actually _publishing_ all this stuff. Getting it online somewhere.

I haven't decided how I'm going to do that yet, but step one is to resurrect that pulumi project I created all the way back in... <!-- TODO Link to post 06_pulumi-first-steps.md -->.

That was on a different machine, remember? So step `i` of step 1 is getting that repo onto drummer. That is easy at least.

<!-- TODO Link to commit 18f92c5beb3bf4a82fd7d57b4fb6200975ebc42a -->

Uhm, that didn't work though. I've asked mr to run the clone in `code/pulumi/higara` but told the git clone to clone into a directory called `pulumi-higara` (by _not_ telling git specifically where to clone).

<!-- TODO Link to commit 700001f4ab7723ec0b35175c9887140582b82bf8 -->

TODO GO FROM HERE

... which means making a repo, which means revisiting my pulumi project from way back in <!-- TODO Link to post 06_pulumi-first-steps.md -->.

Which makes me realise that I don't have that pulumi project on drummer. Or pulumi.

I'll get the code first, which is still on GitHub (but I have _plans_).

<!-- TODO Link to commit 18f92c5 -->

```bash
cd
mr checkout
```

```
mr checkout: /home/stooj/code/pulumi/higara
Cloning into 'pulumi-higara'...
remote: Enumerating objects: 34, done.
remote: Counting objects: 100% (34/34), done.
remote: Compressing objects: 100% (17/17), done.
remote: Total 34 (delta 16), reused 33 (delta 15), pack-reused 0 (from 0)
Receiving objects: 100% (34/34), 33.95 KiB | 409.00 KiB/s, done.
Resolving deltas: 100% (16/16), done.
mr checkout: failed to chdir to /home/stooj/code/pulumi/higara/: No such file or directory

mr checkout: finished (1 failed; 3 skipped)
```

That failed. It checked out the code but it threw an error, because... the paths don't match. I told mr the directory was called `higara` but git cloned the repo into `pulumi-higara`.

Try again:

```bash
cd ~/code/pulumi
rm -rf pulumi-higara
```

<!-- TODO Link to commit 700001f -->

```bash
cd
mr checkout
```

That's better. But pulumi will need installed along with the dependencies and such.

## Pulumi with Nix

Pulumi isn't installed on drummer, and we could easily solve that by adding pulumi to our system packages. But... we don't _need_ pulumi to be installed globally; it's a _project_ dependency, not a system one.

Time for another mind-blowing nix feature; you can have packages that are only available in a particular session. OK, we've actually seen that before so maybe it's not **that** mind-blowing, but this time it's going to be available while we're in a particular _directory_. So when I `cd` into my `pulumi/higara` directory, all the project dependencies will be available. When I `cd` away, they'll be gone.

There are [lots](https://numtide.github.io/devshell/) and [lots](https://www.jetify.com/devbox) and [lots](https://devenv.sh/) and [lots](https://flox.dev/) of projects that do this, all built on Nix and NixPkgs. But they're all designed to help the poor souls that are running some legacy operating system. We're already running NixOS so we can use the native tooling for free. With a flake.

I should look at [organist](https://github.com/nickel-lang/organist) some day though.

First have a look at the official flake templates and grab an empty one:

```bash
nix flake show templates
nix flake init -t templates#empty
```

<!-- TODO Link to commit pulumi-higara 06980d4 -->

Luckily the-nix-way has already done the hard work for us and created [development flake templates](https://github.com/the-nix-way/dev-templates), including one for [pulumi](https://github.com/the-nix-way/dev-templates/blob/main/pulumi/flake.nix).

Give the flake a description first.

<!-- TODO Link to commit pulumi-higara 9ed7dfb -->

I'm not ready for flakehub yet so the nixpkgs input should just be the upstream one.

<!-- TODO Link to commit pulumi-higara 3ce5bfa -->

Wait, what? The **unstable** branch? You can do that?

Yep. Packages for this project will pull from the freshest nixos packages branch without affecting the rest of the system. Neat.

The next bit in [the example](https://github.com/the-nix-way/dev-templates/blob/main/pulumi/flake.nix) has a bunch of hard-coded target systems and then iterates through each one to generate a system configuration.

There's a project called [flake-utils](https://github.com/numtide/flake-utils) that wraps a lot of flake-things in nix functions so I'm going to add that as an input and use it instead.

This flake doesn't _do_ anything yet, but I should probably check it works and generate the flake.lock file as well.

```bash
nix flake update
```

<!-- TODO Link to commit pulumi-higara df834b1 -->

OK, adding the flake-utils wrapper and an empty dev shell.

<!-- TODO Link to commit pulumi-higara 216fd5f -->

I can test this by running the dev shell:

```bash
nix develop
```

That works. Log out of the shell again with ~`logout`~ `exit`.

<!-- TODO Insert image 42-testing_empty_devshell.png -->

Now to install pulumi:

<!-- TODO Link to commit pulumi-higara e04f7a6 -->

And test it:

<!-- TODO Insert image 42-devshell_with_pulumi.png -->

Cool! Pulumi installed :) But only when I run this flake.

If I run pulumi, it'll stick a bunch of stuff in `~/.pulumi`. Yuck, that's a shared location; I want it to be restricted to this directory. This is easily fixed by setting an environment variable called `PULUMI_HOME`.

<!-- TODO Link to commit pulumi-higara baf623a -->

<!-- TODO Insert image 42-pulumi_home_set.png -->

I ran a wee `rm --recursive --force ~/.pulumi` as well to get rid of anything generated when I ran `pulumi about`.

I still need the actual programming language though, and I think Pulumi will need to install packages locally using yarn rather than having them in the flake. This means the flake is impure but I'll get it working first and then fix pulumi and node packaging some other day.

<!-- TODO Link to commit pulumi-higara 818cb68 -->

So I've got a flake, and it seems to be working. Let's make it _seamless_ though. First, install `direnv` in my `nix-config`:

<!-- TODO Link to commit 781c268 -->

Uhm, scratch that. There's an option to get `nix-direnv` in a single configuration step.

<!-- TODO Link to commit af50f8d -->

Hmm. Even that's not the best approach though. The [README](https://github.com/nix-community/nix-direnv?tab=readme-ov-file) recommends using home-manager.

Undo that old commit first:

<!-- TODO Link to commit 0499218 -->

Then add it to `home/common/direnv.nix` and import that in the common home config.

> !NOTE
> Ooh, nix-direnv links to a [home-manager search engine](https://home-manager-options.extranix.com/). And there's been another nix-users falling out over wiki ownership :sigh:. I'll fix them later.

Now that direnv is installed and configured (like smegging magic) it's time to use it in the pulumi repo. I'm a bit squirrely about including an `.envrc` file committed in a repo, but it's my repo so there.

I just `echo "use flake" >> .envrc` in the `pulumi/higara` project and my devshell gets activated.

<!-- TODO Link to commit pulumi-higara 5d912f7 -->

<!-- TODO Insert image 42-direnv_enabled.png -->

Now we are cooking with gas. We might be ready to actually start doing things with Pulumi again.

Wait, git is telling me that it's not tracking `.direnv` and `.pulumi`. Ignore these please Git.

<!-- TODO Link to commit pulumi-higara 21fd6f1 -->

Of course, way back in the day I needed to create a GitHub token for this project and set it to expire after 7 days, so that's probably not going to work any more.

~So time to make another one at [github.com/settings/personal-access-tokens/new](https://github.com/settings/personal-access-tokens/new):~

Actually, time to delete the old token first at [Fine-grained Personal Access Tokens](https://github.com/settings/personal-access-tokens). Then make a new one.

<!-- TODO Turn this into a definition list somehow -->

Token name: Pulumi bootstrap token
Expiration: 7 days
Description: Temporary full access so we can create these repos
Repository access: All repositories
Repository Permissions:

- Administration: Access: Read and write

And I'll add it to the pulumi config again, overwriting the old value (it's still a secret):

```bash
pulumi config set github:token github_pat_abigstringofsecretstuff --secret
```

Ooh, and I get to log into Pulumi on drummer finally.

```
Please choose a stack, or create a new one:  [Use arrows to move, type to filter]
  foo
> prod
  <create a new stack>
```

Uhm, there's two stacks? Why did I make two stacks? It's got to be `prod`, surely.

Ok, I'm logged in and the secret is configured. Commit the updated configuration.

<!-- TODO Link to commit pulumi-higara e612988 -->

Right, let's make sure that Pulumi has everything it needs (it'll install stuff into `.pulumi` or `node-packages`

```bash
pulumi install
```

Pulumi is going to _whine_ and _moan_ because it doesn't like the pulumi binary being in a nix path. Well that's just too bad.

Node is also complaining because there's a new major version of `npm` available (11.3.0) and I'm still using 10.9.2. I wonder if I can fix that...

Uhm, [search.nixos.org](https://search.nixos.org) seems to be having an outage at the moment, which probably means some bastard AI scraper is hammering the same page 4 times a second but trying to dodge any caching.

Fortunately I can search from my terminal:

```bash
nix search nixpkgs nodejs
```

No, that's the most recent version I'm getting at the moment.

OK, fine. Because this is a new "installation" of pulumi, it doesn't know what stack to use.

```bash
pulumi stack select prod
```

Then run a `pulumi up` to check there hasn't been any drift:

```bash
pulumi up
```

No changes detected. Cool.

Now to upgrade any javascript dependencies:

```bash
yarn upgrade
```

Whoops, I'm not actually using yarn in this project (check out my `Pulumi.yaml` file)

```yaml
name: pulumi-higara
description: Pulumi configuration for Higara
runtime:
  name: nodejs
  options:
    typescript: false
    packagemanager: npm
config:
  pulumi:tags:
    value:
      pulumi:template: github-javascript
```

```bash
npm update
```

<!-- TODO Link to commit pulumi-higara 69882e9 -->

And another `pulumi up` to silently apply the package upgrades to my stack.

Cool, so everything is working on `drummer` now. But generating a new GitHub token every time I want to do something is a _pain_, and I don't want a long-lived token with so much power.

A fix for this is to get further embedded with Pulumi Cloud. If I run pulumi in the Pulumi cloud instead of on my laptop, it won't _need_ a GitHub token. This is because I'll need to install the Pulumi GitHub app and it'll generate a token on-demand.

But maybe I don't want to use GitHub anyway, and apparently Pulumi [better support for GitLab](https://www.pulumi.com/blog/gitlab-better-than-ever/). Oh, it doesn't support deployments yet though 😢. Well that's that idea out the window.

But at least I now have my Pulumi project locally. Next step is to set up deployments.

TODO: Set up deployments

# References

- [Intro - devshell](https://numtide.github.io/devshell/)
- [Devbox: Portable, Isolated Dev Environments](https://www.jetify.com/devbox)
- [Fast, Declarative, Reproducible, and Composable Developer Environments - devenv](https://devenv.sh/)
- [Flox | Your dev environment, everywhere](https://flox.dev/)
- [nickel-lang/organist: Control all your tooling from a single console](https://github.com/nickel-lang/organist)
- [Enabling NixOS with Flakes | NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled)
- [the-nix-way/dev-templates: Dev environments for numerous languages based on Nix flakes](https://github.com/the-nix-way/dev-templates)
- [FlakeHub](https://flakehub.com/)
- [numtide/flake-utils: Pure Nix flake utility functions](https://github.com/numtide/flake-utils)
- [nix-community/nix-direnv: A fast, persistent use_nix/use_flake implementation for direnv](https://github.com/nix-community/nix-direnv)
- [direnv – unclutter your .profile | direnv](https://direnv.net/)
- [Home Manager - Option Search](https://home-manager-options.extranix.com/)
