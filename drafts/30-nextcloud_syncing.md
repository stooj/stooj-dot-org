Title: Nextcloud syncing
Date: 2025-03-30T23:11:50
Category: NixOS

Did I mention that I got a nextcloud account with Hetzner! They sell a [managed Nextcloud service](https://www.hetzner.com/storage/storage-share/) for not very manys, and Nextcloud is high on the list of things I don't want to manage myself (right now).

It doesn't do [Collabora office](https://www.collaboraonline.com/) out of the box, but I've never actually used that anyway. What I **do** use it for is a way of syncing my home directory files from one machine to another, and making them accessible to me when I'm not at a computer. This might be an ill-advised usage, but it hasn't exploded so far.

The heart of my setup uses [bind mounts](https://www.baeldung.com/linux/bind-mounts), which are a magical way of having two (or more) directories in your filesystem point to the same place on your hard drive. That sentence isn't actually true, but it's a useful lie.

```bash
cd ~/code/nix/nix-config
git checkout -b nextcloud-client
```

There are a couple of things I don't like about the nextcloud client.

1. It's a desktop app, so I can't have it running as a service. Instead it fills up my system tray and needs X.
2. It stores authentication information in the configuration file, so I can't really manage that with nix

Turns out though, I don't **need** to use the nextcloud gui client. There's a [command-line utility](https://docs.nextcloud.com/desktop/3.6/nextcloudcmd.html)  included in the package that I can use instead.

Instead of adding the package to my config though I'm going to use a `nix-shell` to figure out *how* I'm going to configure things first, and what the requirements are. `nix-shells` are cool and I use them all the time. They are similar to, but not the same as, `nix shells`. Well done nix :sigh:

## Testing things in a temporary shell

```bash
# Install nextcloud-client in a temporary environment
nix-shell --packages nextcloud-client
```

When I log out of that shell session, nextcloud-client won't be installed any more. This turns out to be unbelievably handy for trying out things.

The good news is that the `nix-shell` command worked.  The bad news is that it generated hundreds of identical warnings:

```
warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
```

It's only a warning so I'm going to ignore it for now and hope it goes away.

```bash
nextcloudcmd
```

```
nextcloudcmd - command line Nextcloud client tool

Usage: nextcloudcmd [OPTION] <source_dir> <server_url>

A proxy can either be set manually using --httpproxy.
Otherwise, the setting from a configured sync client will be used.

Options:
  --silent, -s           Don't be so verbose
  --httpproxy [proxy]    Specify a http proxy to use.
                         Proxy is http://server:port
  --trust                Trust the SSL certification.
  --exclude [file]       Exclude list file
  --unsyncedfolders [file]    File containing the list of unsynced remote folders (selective sync)
  --user, -u [name]      Use [name] as the login name
  --password, -p [pass]  Use [pass] as password
  -n                     Use netrc (5) for login
  --non-interactive      Do not block execution with interaction
  --max-sync-retries [n] Retries maximum n times (default to 3)
  --uplimit [n]          Limit the upload speed of files to n KB/s
  --downlimit [n]        Limit the download speed of files to n KB/s
  -h                     Sync hidden files, do not ignore them
  --version, -v          Display version and exit
  --logdebug             More verbose logging
  --path                 Path to a folder on a remote server
```

First thing is that I need a source directory then. Creating it manually for now:

```bash
mkdir --parents ~/.local/share/nextcloud/ginstoo
```

And give it a server name:

```bash
nextcloudcmd ~/.local/share/nextcloud/ginstoo https://nc.ginstoo.net
```

```
Please enter username: ******
Password for account with username ******:

...
Server replied with an error while reading directory \"\" : Host requires authentication"
```

Ah. 2FA. Try with an app password.

And get an avalanche of output. I already have a bunch of stuff on Nextcloud.

So what's next? Well, I don't want to sync *everything*, I only want to sync a handful of directories. Let's try with a small once first:

```bash
nextcloudcmd --path /downloads ~/.local/share/nextcloud/ginstoo https://nc.ginstoo.net
```

Hmm, that pulled the files to my local disk but didn't create the parent directory (`downloads`) on my local machine. What if I give it a path terminator thing:

```bash
nextcloudcmd --path /downloads ~/.local/share/nextcloud/ginstoo/ https://nc.ginstoo.net
```

Nope. No change, still downloaded to the same place. OK, I need to create the directories beforehand, that's actually good news for the old bind mounting.

```bash
mkdir --parents ~/.local/share/nextcloud/ginstoo/downloads
nextcloudcmd --path /downloads ~/.local/share/nextcloud/ginstoo/downloads https://nc.ginstoo.net
```

Sweet! That worked. But I'm fed up of typing a username and password in every time, so time to fix that by using the `~/.netrc` file instead.

```bash
cat << EOF > ~/.netrc
machine nc.ginstoo.net
login ******
password ************
EOF
```

Can we have more than one path? (Note I've added the `-n` arg to use `~/.netrc`)

```bash
mkdir --parents ~/.local/share/nextcloud/ginstoo/public
nextcloudcmd \
    -n \
    --path /downloads ~/.local/share/nextcloud/ginstoo/downloads \
    --path /public ~/.local/share/nextcloud/ginstoo/public \
     https://nc.ginstoo.net
```

No. That didn't work. Re-reading the help output it's obvious that it wouldn't - the local path isn't part of the `--path` argument.

As a wild experiment, what if we supply two `--path` options with a single `source_dir`?

```bash
nextcloudcmd \
    -n \
    --path /downloads \
    --path /public \
    ~/.local/share/nextcloud/ginstoo \
     https://nc.ginstoo.net
```

That started to work, but my `.netrc` is wrong :confused:

```
 [ OCC::NetrcParser::parse ]:    error fetching value for "machine
```

:lol: Netrc parsing is broken just now: [[Bug]: nextcloud client failed to parse netrc · Issue #7177 · nextcloud/desktop](https://github.com/nextcloud/desktop/issues/7177)

So take out the `-n` and try again. This downloaded the `downloads` and `public` directory to `~/.local/share/nextcloud/ginstoo`, which I suppose I should have guessed would happen.

Aaaand it nested `downloads` into `public` on the remote Nextcloud directory, so I'm taking a minute to tidy up that mess.

<!-- TODO insert 30 minutes later gif -->

OK, I think I have enough information to be getting on with the official configuration.

Here's the plan:

1. Use Systemd to make services and timers for nextcloudcmd.
2. Have a different service and timer for each directory I want to sync.
3. Not bother with the `~/.netrc` file (I never liked it) and store the username & password as environment variables.
4. Pass those variables to the systemd unit file using the EnvironmentFile option.

But first, time to tidy up the local machine:

```bash
logout  # Now nextcloud-client isn't installed any more
rm -r ~/.local/share/nextcloud
rm ~/.netrc
find ~ -type d -iname nextcloud  # To search for any other files that Nextcloud might have made.
```

## Writing the config

Home manager has an `services.nextcloud-client` option, but according to the [code](https://github.com/nix-community/home-manager/blob/7fb8678716c158642ac42f9ff7a18c0800fea551/modules/services/nextcloud-client.nix) it creates a systemd service to launch the desktop client. **Not** what I want.

So it needs to be installed as a system package. This should be moved out of `configuration.nix` at some point but for now that file is small enough and there's only one machine to configure anyway. Everyone gets Nextcloud!

<!-- TODO Link to commit 8760bd7 -->

pindy and I have similar home directory layouts and they map to the same directories on Nextcloud. They're so similar in fact that the _only_ difference between our configurations would be the username and password. 

So the bulk of the configuration can go into `common`.

First, an empty configuration that gets included as part of the common user configuration:

<!-- TODO Link to commit 20f7f09 -->

Then create a systemd service unit file that will sync the downloads directory. Instead of hard-coding the username, password, and hostname, they are going to be passed in as environment variables. I need to include `pkgs` as an input now so I can explicitly set the path for the `nextcloudcmd` binary. Anything else in here is just standard systemd unitfile stuff.

Note: I'm escaping the _systemd_ environment variables in the `ExecStart` command because nix uses the same syntax for... not variables... whatever they are called in nix. Properties? I can't remember. The things that look like variables but aren't variables because they are bound and don't vary.

<!-- TODO Link to commit 8b930de -->

This will build, but the service will fail because those environment variables aren't populated yet. Going to ignore that for now, but the plan is to hopefully pass different values for the different users. Hopefully.

Now to add a timer so the service will fire every hour.

<!-- TODO Link to commit 4b4590c -->

Right, so I need to find a way to _include_ those environment variables in the unit file. I can use sops-nix `template` feature to create a list of environment variables that have the secrets in them, then consume the environment file as part of the systemd unit file.

Each user is going to need their own Nextcloud secrets.

```bash
nix shell nixpkgs#sops --command sops home/stooj/secrets.yaml
```

I add three secrets:

- `nextcloud_url`
- `nextcloud_user`
- `nextcloud_password`

<!-- TODO Link to commit 49879ec -->

And do the same for pindy.

```bash
nix shell nixpkgs#sops --command sops home/pindy/secrets.yaml
```

<!-- TODO Link to commit 9862980 -->

Then I tell sops to use that file as the default for user secrets. Because it's in the common directory, I specify a path that's one above and then down into whatever the username is (hopefully `stooj` in this case, and also `pindy`).

<!-- TODO Link to commit 6141e64 -->

Then I need to set up the sops template and add the environment variables. I bet this can actually live in the `common` directory.

Declare the sops secrets - they don't need any configuration so their config blocks are blank.

<!-- TODO Link to commit 7baf6f6 -->

Add `config` as an input because that's where the sops secrets are stored and then create the template file that has a bunch of environment declarations in it with the values of the secrets. Note that "nextcloud.env" needs to be in quotes because it's a single thing, not a nested nix `nextcloud = { env = ... }; };` thing.

<!-- TODO Link to commit 6a064ec -->

Finally add the environment file to the systemd unit file.

<!-- TODO Link to commit c684b13 -->

And finally finally the unit file needs to load **after** the sops-nix service has loaded because it now relies on secrets.

<!-- TODO Link to commit 9fc73b9 -->

Time to give it a whirl:

```bash
sudo nixos-rebuild switch --flake .
```

Yuss. No errors. And did it create the secrets file?

```bash
cat ~/.config/sops-nix/secrets/rendered/nextcloud.env
```

```
NEXTCLOUD_USERNAME = "******"
NEXTCLOUD_PASSWORD = "******"
NEXTCLOUD_URL = "******"
```

Yes it bloomin' well did!

And did the environment file get set on the service properly?

```bash
systemctl show --user nextcloud-downloads-autosync.service | grep EnvironmentFiles
```

```
EnvironmentFiles=/home/stooj/.config/sops-nix/secrets/rendered/nextcloud.env (ignore_errors=no)
```

What a triumph!

And is the service working?

```bash
systemctl status --user nextcloud-downloads-autosync.service
```

Womp Womp. 

```
...
Active: failed (Result: exit-code) 
...
nextcloudcmd[8470]: Source dir '/home/stooj/.local/share/nextcloud/downloads/' does not exist.
...
```

Of course, the directory doesn't exist yet. Because we need to configure some mounts for them.

In the before nix time I used the nextcloud-client GUI program which just synced _everything_ to/from my nextcloud server, so I needed a root directory to point the sync to. That's what `~/.local/share/nextcloud` is for.

Then I'd create `bind` mounts from my sensible home directory directories to inside the nextcloud directory, e.g.:

- `$HOME/downloads` --> `$HOME/.local/share/nextcloud/downloads`
- `$HOME/documents` --> `$HOME/.local/share/nextcloud/documents`

etc.

Why do I still want to do that? :thinkingface: Now that I'm creating a different sync for each directory, I don't need a root directory for nextcloud any more, I can point the service straight at my top-level home dir directory. Right?

Like this:

<!-- TODO Link to commit fd4fb56 -->

Another rebuild later...

<!-- TODO Insert very excited gif -->

That worked perfectly. My `~/downloads` directory now has stuff in it. 

Going to reboot and maybe log in as pindy to see what happens.

What happens is that it works beautifully for both users. `$HOME/downloads` now looks marvellously complete.

Time to add in the same for other directories. Because nix is a functional language and I suck at purely functional languages, the obvious way to go about this would be to copy and paste the services and timers multiple times and have a giant wall of code.

Not having that though. Got to do it more proper.

If you search on the internets for "loop in nix" or "iterate over array in nix" you will get a lot of complicated answers that don't make a lot of sense to a beginner and use stuff from `lib` or builtins or flake-utils. That's because you, like me, are asking the wrong question.

I just need a function. Two functions actually.

One for the service and one for the timer. It'll take one argument (nix functions **can only** take one argument, so that's easy) which will be the name of the directory and it will generate the code needed for the service or timer.

Something like this:

<!-- TODO Link to commit c075b94 -->

The diff looks bigger than it actually is. I moved the systemd service config and timer config **outside** of the configuration block into a `let` expression (which is where you assign names to values in nix - note this is *not* assigning variables).

Then I switched out the hard-coded `downloads` for the `${directory}` name. And wrapped this in a function called `ncService` that takes `directory` as an argument.

And the same for the timer config, now called `ncTimer`.

Then, back in the `systemd.user` configuration, I replace the individual service and timer configurations with calls to the appropriate functions, with `downloads` passed as the argument.

There's another bit of tidying up I can do here; when I add more directories I'll have that `services` option repeated a bunch. Wrap it like this:

<!-- TODO Link to commit b1615d3 -->

That'll mean each directory doesn't need to be prefixed with `timers` or `services`.

Now to actually add the other directories I wanted. It's very easy now.

<!-- TODO Link to commit 7f21044 -->

One other thing, all the timers are set to start at exactly the same time (5 minutes after boot). This can be randomized so it'll start at the `OnBootSec` value, plus a random interval up to `RandomizedDelaySec`. I think that's how it works.

<!-- TODO Link to commit f769300 -->

Woah. That's it. Nextcloud is configured, and my home directory looks like it has stuff in it!

I call that a result.

No, hang on. A whole hour is too long to wait.

<!-- TODO Link to commit 69036fa -->

```bash
cd ~/code/nix/nix-config
git checkout main
git merge nextcloud-client
git branch -d nextcloud-client
```

# References

- [Install nextcloudcmd — Nextcloud Client Manual 3.6.6 documentation](https://docs.nextcloud.com/desktop/3.6/nextcloudcmd.html)
- [Nextcloud - NixOS Wiki](https://nixos.wiki/wiki/Nextcloud#Clients)
- [NextCloud Client Command Line – Terence Eden’s Blog](https://shkspr.mobi/blog/2023/04/nextcloud-client-command-line/)
- [[Bug]: nextcloud client failed to parse netrc · Issue #7177 · nextcloud/desktop](https://github.com/nextcloud/desktop/issues/7177)
- [Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-services.nextcloud-client.enable)
- [home-manager/modules/services/nextcloud-client.nix at master · nix-community/home-manager · GitHub](https://github.com/nix-community/home-manager/blob/master/modules/services/nextcloud-client.nix)
- [Using environment variables in systemd units | Flatcar Container Linux](https://www.flatcar.org/docs/latest/setup/systemd/environment-variables/)
- [nix-shell vs. nix shell - Kevin Macksamie](https://kevinmacksa.me/post/20240111-nix-shell/)
- [Environment variables - NixOS Wiki](https://wiki.nixos.org/wiki/Environment_variables)
- [Nix language basics - Functions — nix.dev documentation](https://nix.dev/tutorials/nix-language.html#functions)
- [systemd.timer(5) — Arch manual pages](https://man.archlinux.org/man/systemd.timer.5)
