Title: Pulumi First Steps
Date: 2024-10-12T08:41:07
Category: Pulumi

We've got one laptop whose configuration is entirely managed by code, but now I
have a repo that's just sitting on `proteus`' hard drive. It's not "managed" by
anything, and it's not "declared".

I could throw it up on GitHub, but then GitHub has this unmanaged repo. That's
probably fine in the grand scheme of things, but what if we can manage GitHub
configuration with code? Then we can manage GitHub stuff in a similar way to
managing `drummer`'s OS; with code, and we have a greppable source of truth.

Pulumi.

```
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                     I WORK FOR PULUMI. THEY EMPLOY ME.                     %%
%%           I WOULD BE USING PULUMI EVEN IF THEY DIDN'T EMPLOY ME            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%            BUT YOU HAVE NO REASON TO BELIEVE ME WHEN I SAY THAT            %%
%%           SO, YOU KNOW, BE SCEPTICAL AND MAKE YOUR OWN DECISIONS           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                           PULUMI IS GREAT THOUGH                           %%
%%                      THEY DIDN'T PAY ME TO SAY *THAT*                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```

I don't want to have to manage state or locking or anything, and I'm already
using GitHub, so I'm not dogmatic about using closed-source SaaS products. If
you are, feel free to run your own git forge and state hosting. But pulumi makes
it very easy to just get going with their website, so that's the way we're
going.

A wee confession before I get started though; I'm going to do this on `proteus`
to begin with (Gin's KDE-Neon installation). `drummer` still doesn't have any
kind of desktop or window manager, let alone a browser. We're going to need a
web browser for this.

And a password manager. You do have one of them, right? I'm using
[BitWarden](https://bitwarden.com/); it's open source, self-hostable, and makes
it easy for me to give them money (I have the Families plan).

Right, so are you on your partner's working machine? Cool.

If we're going to manage repos hosted on GitHub with Pulumi, we're going to
need two things:

1. A [GitHub](https://github.com) account.
2. A [Pulumi](https://pulumi.com) account.

<!-- TODO Walkthrough of signing up to both those services -->

First, installing `pulumi`

<!-- TODO Install pulumi on kde-neon -->

```bash
curl --fail --silent --show-error \
    --location https://get.pulumi.com \
    --output pulumi.sh
cat pulumi.sh
sh pulumi.sh
```

The installer adds a new directory (`~/.pulumi/bin`) to your path, so close your
terminal and open a new one to update `$PATH`.

Now to set up a new repo for our pulumi code. I'm going to call it
`pulumi-higara`, it's going to be the pulumi code for the higara project. I
don't know what that means either. Names are hard.

```bash
mkdir --parents ~/code/unmanaged/pulumi-higara
cd ~/code/unmanaged/pulumi-higara
```

Pulumi has a bunch of starting [templates](https://github.com/pulumi/templates) that you can use to bootstrap your
project. Nice, they have some `github` ones and I'm going to use the `javascript`
one. I figure this blog will be a python or a golang project, so adding a
javascript project means I can have different development environments later on.
It'll be good learning and good content.

Better actually install `npm` first. This is a KDE-Neon machine, so:

```bash
sudo apt install npm
```

Start the new project in the `~/code/unmanaged/pulumi-higara` directory:

```bash
pulumi new github-javascript
```

Pulumi will run through a log-in process for your terminal. Just log in as
you're told using a web browser.

Project name: pulumi-higara
Project description: Pulumi configuration for Higara
Stack name: prod
Package manager: npm

Then there is a comment at the end:

```
To target a specific GitHub organization or an individual user account, set the
GitHub owner configuration value.
```

And then it asks for a github authentication token. Uuuh... Whoops, press ENTER
for the default blank one.

<!-- TODO Link to commit  -->

Set the `github:owner` first - pulumi has a tool to write to the `Pulumi.yaml`
file so you don't need to do it manually and risk breaking the YAML indentation.

```bash
pulumi config set github:owner stooj
```

<!-- TODO Link to commit  -->

And let's get an auth token for GitHub - go to https://github.com/settings/personal-access-tokens/new:

Token name: Pulumi bootstrap token
Expiration: 7 days
Description: Temporary full access so we can create these repos
Repository access: All repositories
Repository Permissions:

- Administration: Access: Read and write

We can add this to our Pulumi config as well, because the pulumi config can have
encrypted secrets (just remember to include the `--secret` flag):

```bash
pulumi config set github:token github_pat_abigstringofsecretstuff --secret
```

<!-- TODO Link to commit  -->

Check that it's working by creating the repo in the template (`demo-repo`)

```bash
pulumi up
```

Pulumi will show you a preview of what it's going to do first:

1. Create the stack in pulumi-cloud (the pulumi SaaS UI)
2. Create a GitHub repo called `demo-repo`

There's also an `Output,` that's actually what the repo is going to be called.
Pulumi adds a random string to the end of names by default. We'll deal with that
later.

For fun, might as well create it to check that I got the token permissions
correct.

Cool, that actually worked. I don't know why I'm surprised. Let's bin that repo
now:

```bash
pulumi destroy
```

Pulumi will destroy the repo (and the Pulumi stack). Nice!

Time to actually configure our actual repo. First, we need to correct the name
and give it a still vague but more accurate description.

<!-- TODO Link to commit  -->

One thing I never want to happen is for this repository to be deleted, even if
we run another `pulumi destroy`. You can use a pulumi option to say "don't
delete this even if I try to".

<!-- TODO Link to commit  -->

The other thing we want to make sure is that the repo is actually _named_ the
right thing. You can tell pulumi to use a literal name rather than adding a
random string to the end of the name:

Let's create the repo again:

```bash
pulumi up
```

And watch it fail, because my code has syntax issues. Turns out I've **really**
come to rely on language servers and linters and I didn't spot the errors.
Embarassing.

<!-- TODO Link to commit  -->

We have a repo. Now to add the code we have to the repo we created. Uhm. Feels
like pulling yourself up by your shoelaces.

```bash
git remote add origin git@github.com:stooj/pulumi-higara.git
git branch --move --force main
git push --set-upstream origin main
```

Nice, that's my pulumi repo using GitHub to host the repo. Let's add my Nix
config as well.

First of all, that `repo` export is just called `repo`. We're going to have more
than one repo to export, so lets change the name so we don't have collisions
(and it better represents what the export actually is in the context of the
project.)

<!-- TODO Link to commit  -->

Now to add our new repo. It's going to be pretty similar to the old one

<!-- TODO Link to commit  -->

Deploy it!

```bash
pulumi up
```

You'll see in the preview that `repo` has become `pulumiRepo`. We're not using
exports yet, so it's just a cosmetic change just now. It only affects what's
printed to the terminal when you run an `up`, doesn't affect the repo itself.

OK, now I can push the `nix-config` repo to it's new home.

```bash
cd ~/code/unmanaged/nix-config
git remote add origin git@github.com:stooj/nix-config.git
git branch --move --force main
git push --set-upstream origin main
```

Finally, time to create a repo to host these ramblings.

<!-- TODO Link to commit  -->

And turn my directory of markdown documents into a repo.

```bash
cd ~/code/unmanaged/stooj-dot-org
git remote add origin git@github.com:stooj/stooj-dot-org.git
git branch --move --force main
git push --set-upstream origin main
```

# Resources

- https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#repository-permissions-for-contents
- https://www.pulumi.com/docs/iac/concepts/resources/names/
- https://www.pulumi.com/docs/iac/concepts/resources/names/#autonaming
- https://www.pulumi.com/docs/iac/concepts/options/retainondelete/
