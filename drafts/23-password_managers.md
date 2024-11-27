Title: Password Managers
Date: 2024-11-25T21:55:51
Category: NixOS

I mentioned before that I'm using [pass](https://www.passwordstore.org/), but you may have noticed that I don't actually have any of that on `drummer` yet.

Time to fix that before I need to log into something.

## Passowrd Managers

```bash
cd ~/code/nix/nix-config
git checkout -b password-managers
```

Password-store can be [managed using home-manager](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.password-store.enable), so that's nice. But I've just noticed [programs.password-store.settings](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.password-store.settings), which shows me there's going to be a wrinkle here: it uses `$XDG_DATA_HOME` for it's defaults. That won't be a *huge* issue because if they are missing it'll default to the correct value, but it's a bit *implicit*.

So instead of doing the password manager, I'm going to set up XDG first.

## XDG directories

I like my home directory to be neat and ordered and as uncluttered as I can make it. If I can put config into the `~/.config` directory, that's where it should go. State? Well that should go in `~/.local/state`. Cache? `~/.cache` of course!

I also like my user-facing directories to be called a certain thing, and lowercased. I made this decision a long time ago in an effort to make my Shift keys last a little longer, and I've been fighting every OS on it ever since. Dunno why, but they all love their capitalized directory names.

I do not.

It's easy to solve with home-manager though.

```bash
git checkout -b xdg-user-dirs
```

Wait, I just thought of an issue.

For all the `XDG_*` environment variables to be useful, home-manager needs to be managing the shell, which is currently bash.

So instead of doing the XDG config, I'm going to set up bash properly.

## Bash

```bash
git checkout -b manage-bash
```

And enable it as a common option for all users.

<!-- TODO Link to commit 78a4af0 -->

This is a relief actually, because I like my shell prompt to be a little fantoush[^1].

Cool, when I apply the config now I have `~/.bashrc`, `~/.bash_profile`, and `~/.profile`. `~/.profile` includes a home-manager controlled dumping ground for all manner of configurations including environment variables, so that should sort out environment variables for my X-session nicely.

Completion pleaseee:

<!-- TODO Link to commit 16e7b37 -->

According to [the docs](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.bash.enableCompletion), you need to enable bash completion in the system configuration as well as in the home-manager configuration, or muck about with linking paths in the nix store, which sounds complicated. The setting for that is [here](https://search.nixos.org/options?channel=unstable&show=programs.bash.completion.enable).

Aand it didn't work. 

```
       error: The option `programs.bash.completion' does not exist. Definition values:
       - In `/nix/store/i98i3a36c0qn9l96ndjsrdq22scvmyl6-source/bash.nix':
           {
             enable = true;
           }
```

Why not? My system doesn't think that `programs.bash.completion` is a thing. Oooh, probably because I'm searching unstable and there has maybe been a change to the option name between my current version (24.05) and unstable.

If I [change the search to 24.05](https://search.nixos.org/options?channel=24.05&show=programs.bash.enableCompletion&from=0&size=50&sort=relevance&type=packages&query=bash), right enough the option used to be called `programs.bash.enableCompletion`. I can see why they changed it.

<!-- TODO Link to commit f908eca -->

I've one more thing to fix for this branch which is *sort of* bash-ish; that's setting `readline` to use vi-mode. I'm only setting it for me though, because pindy would string me up by my intestines if I took away her emacs mode terminal.

<!-- TODO Link to commit 6ed4a2d -->

## Back to XDG

First, pull in the bash changes.

```bash
cd ~/code/nix/nix-config
git checkout xdg-user-dirs
git merge manage-bash
```

Right, enable xdg for all users.

<!-- TODO Link to commit 8dec6a7 -->

And check it worked:

```bash
echo $XDG_CONFIG_DIR
```

Hmm. Nothing. Oh, it needs to be in a new shell session

```bash
bash
echo $XDG_CONFIG_DIR
```

Hmm. Still nothing. Ugh, do I need to reboot? Maybe if I just source `.profile`?

```bash
source ~/.profile
echo $XDG_CONFIG_DIR
```

Argh! Still nada! I'm pretty sure it's set using `~/.profile`, what's in there:

```bash
cat ~/.profile
```

```
. "/etc/profiles/per-user/stooj/etc/profile.d/hm-session-vars.sh"
```

OK, what's in `/etc/profiles/per-user/stooj/etc/profile.d/hm-session-vars.sh`?

```bash
cat /etc/profiles/per-user/stooj/etc/profile.d/hm-session-vars.sh
```

```
# Only source this once.
if [ -n "$__HM_SESS_VARS_SOURCED" ]; then return; fi
export __HM_SESS_VARS_SOURCED=1

export GNUPGHOME="/home/stooj/.gnupg"
export LOCALE_ARCHIVE_2_27="/nix/store/c0v6ayqhwap6g8rdzibk9qqcljff1dji-glibc-locales-2.39-52/lib/locale/locale-archive"
export XDG_CACHE_HOME="/home/stooj/.cache"
export XDG_CONFIG_HOME="/home/stooj/.config"
export XDG_DATA_HOME="/home/stooj/.local/share"
export XDG_STATE_HOME="/home/stooj/.local/state"
```

YES! It's THERE! Why you not work?!?

Oh, wait. What are those first three lines? Ugh, why is that? Do I need to reboot every time I add a new bash env var? Surely not...

Fine though, I'll do it **THIS ONE TIME**. This isn't over though! I must be doing something wrong here.

```bash
# Save save save all the files
sudo reboot
```

And back.

```bash
echo $XDG_CONFIG_DIR
```

<!-- TODO Insert gif of someone hysterically laughing -->

Here's a philosophical question:

> What is the difference between `$XDG_CONFIG_DIR` and `$XDG_CONFIG_HOME`?

I mean, apart from the spelling?

```bash
echo $XDG_CONFIG_HOME
```

Do you ever wish you could rewind time?

Ahem. Where was I?

RIGHT! Home directories, and how they should be lowercased, and how I would like them to be auto-created for me because I want my system to be bootstrapped from nothing to as complete as possible as part of the installation.

Time to get a bit fancy again with those `let in` blocks

<!-- TODO Link to commit c8f1142 -->

`createDirectories`, bizarrely, will create the directories if they don't exist already. And each named directory has a proper lower-cased name as is right and proper.

```bash
ls ~
```

Lovely. That warms my heart.

## Back to the password manager

```bash
cd ~/code/nix/nix-config
git checkout password-managers
git merge xdg-user-dirs
```

And then turn it on.

<!-- TODO Link to commit 680ece1 -->

And mainly for the extra config, set the default length for the password generator to something with extra padlocks.

<!-- TODO Link to commit ffe643e -->

And now to actually clone the passwords. This _could_ go in a new `mr` file (I should move it out of `stooj/default.nix` anyway) but I think it logically belongs in the password-store configuration.

Ooh, and I need to add the fingerprint for our personal gitlab server. I don't think I documented how to do this before, so here it is now:

```bash
ssh-keyscan code.ginstoo.net
```

<!-- TODO Link to commit a7b3b0d -->

Apply and test:

```bash
cd ~/code/nix/nix-config
sudo nixos-rebuild switch --flake .
cd ~
mr checkout
```

Password store cloned and no fingerprint asked for. Success. I think. Do I need to reboot again? That's going to get very annoying.

It worked after a reboot. I must be doing something wrong, did I open up a new terminal to test when I did this last night? I can't remember. I'll test with the next thing, whatever that ends up being.

To get this working for pindy I need to replicate the `mr` enablement and the `gnupg` setup, so I should probably do some tidying up while I'm at it.

First, move my gpg config into a separate module:

<!-- TODO Link to commit 7b4b968 -->

Oops, and enable it for everyone

<!-- TODO Link to commit 364f5bb -->

Do the same for mr. All users:

<!-- TODO Link to commit 91c7a58 -->

And move the mr configuration into a new module

<!-- TODO Link to commit 8d86f75 -->

GPG for gin. Huh... what's her GPG key...?

Import it into the repo:

```bash
curl "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x4e26e024e44e710c3e1d4e5be4da33ee8d1aa143" >> ~/code/nix/nix-config/keys/pindy.asc
```

And mark it as trusted and stuff.

<!-- TODO Link to commit f2fae2b -->

I should also add our keys to each other because we both trust each other as being owners of those keys.

<!-- TODO Link to commit 751ab18 -->

Finally I can add pindy's password-store to their mr config.

<!-- TODO Link to commit 09c2332 -->

```bash
git checkout main
git merge password-managers
```

I should tidy up some branches too:

```bash
git branch -d manage-bash
git branch -d xdg-user-dirs
git branch -d password-managers
```

[^1]: [fantoush - Wiktionary, the free dictionary](https://en.wiktionary.org/wiki/fantoush)

# References

- [programs.password-store](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.password-store.enable)
- [programs.password-store.settings](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.password-store.settings)
- [XDG user directories - ArchWiki](https://wiki.archlinux.org/title/XDG_user_directories)
- [Filesystem Hierarchy Standard - NixOS4Noobs](https://jorel.dev/NixOS4Noobs/fhs.html)
- [XDG Base Directory - ArchWiki](https://wiki.archlinux.org/title/XDG_Base_Directory)
- [home-manager/modules/misc/xdg.nix at master · nix-community/home-manager · GitHub](https://github.com/nix-community/home-manager/blob/master/modules/misc/xdg.nix)
- [programs.bash](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.bash.enable)
- [programs.bash.enableCompletion](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.bash.enableCompletion)
- [programs.bash.completion.enable - nixos unstable option](https://search.nixos.org/options?channel=unstable&show=programs.bash.completion.enable)
- [programs.bash.enableCompletion - nixos 24.05 option](https://search.nixos.org/options?channel=24.05&show=programs.bash.enableCompletion&from=0&size=50&sort=relevance&type=packages&query=bash)
- [programs.readline.extraConfig](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.readline.extraConfig)
- [xdg.userDirs](https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.userDirs.enable)
