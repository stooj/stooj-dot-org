Title: Create the screenshots directory for Flameshot
Date: 2024-12-03T20:47:00
Category: NixOS

Remember back in the <!--TODO Insert link to 18-install_flameshot --> flameshot post where I manually created a directory for the screenshots? You know, when I had everything ticked off my "manual changes list" and then I had to add another thing?

I hate that. I'm gonna fix it.

```bash
cd ~/code/nix/nix-config
git checkout -b create-directory-for-flameshot
```

`home.activation` can be used to run idempotent commands or scripts during the activation phase. There's a `run`  function that makes sure you can `dry-run` the script/command as well.

If the script changes anything, it needs to be run after the `writeBoundary` in the [directed acyclic graph](https://en.wikipedia.org/w/index.php?title=Directed_acyclic_graph) so I've done that too. Here's the first attempt:

<!-- TODO Link to commit b5b07f7 -->

Try and test it...

```bash
sudo nixos-rebuild switch --flake .
```

Seems to work so far. Does it actually do what it's meant to?

```bash
rmdir ~/pictures/screenshots
sudo nixos-rebuild switch --flake .
[ -d "~/pictures/screenshots" ] && echo "It's there!" || echo "It's not there"
```

It's not there. Hmm.

Is it the `homeDirectory` thing there (I'm assuming it runs/evaluates for each user but that might be nonsense)? What if I create a silly directory without using the `homeDirectory` variable?

<!-- TODO Link to commit b9fd841 -->

```bash
sudo nixos-rebuild switch --flake .
[ -d "/tmp/foo/bar/blah" ] && echo "It's there!" || echo "It's not there"
```

Cool, it's there. 

What if I use a variable to create a directory?

<!-- TODO Link to commit dc8cb99 -->

```bash
sudo nixos-rebuild switch --flake .
```

Oooh! Interesting error!

```
× home-manager-stooj.service - Home Manager environment for stooj
     Loaded: loaded (/etc/systemd/system/home-manager-stooj.service; enabled; preset: enabled)
     Active: failed (Result: exit-code) since Tue 2024-12-03 21:17:35 CET; 63ms ago
   Duration: 6min 45.335s
    Process: 12370 ExecStart=/nix/store/qa3ndiwqwvi71pkjmj7v862sci9ikn9m-hm-setup-env /nix/store/y4gv5801c8cn68kyysy7n654ahz63hav-home-manager-generation (code=exited, status=1/FAILURE)
   Main PID: 12370 (code=exited, status=1/FAILURE)
         IP: 0B in, 0B out
        CPU: 220ms

Dec 03 21:17:35 drummer hm-activate-stooj[12370]: Activating linkGeneration
Dec 03 21:17:35 drummer hm-activate-stooj[12370]: Cleaning up orphan links from /home/stooj
Dec 03 21:17:35 drummer hm-activate-stooj[12370]: No change so reusing latest profile generation 54
Dec 03 21:17:35 drummer hm-activate-stooj[12370]: Creating home file links in /home/stooj
Dec 03 21:17:35 drummer hm-activate-stooj[12370]: Activating createXdgUserDirectories
Dec 03 21:17:35 drummer hm-activate-stooj[12370]: Activating flameshot_dir
Dec 03 21:17:35 drummer hm-activate-stooj[12616]: mkdir: cannot create directory ‘/tmp/foo/bar/blah/stooj’: Permission denied
Dec 03 21:17:35 drummer systemd[1]: home-manager-stooj.service: Main process exited, code=exited, status=1/FAILURE
Dec 03 21:17:35 drummer systemd[1]: home-manager-stooj.service: Failed with result 'exit-code'.
Dec 03 21:17:35 drummer systemd[1]: Failed to start Home Manager environment for stooj.
warning: error(s) occurred while switching to the new configuration
```

I wonder who that directory belongs to? Maybe pindy?

```bash
stat /tmp/foo/bar/blah/ --format=%U
```

It's `pindy`. But it *did* try to create a directory called `stooj`, presumably during the `stooj` activation step. So my first attempt can't have been far off the mark...

How about I go back to my first attempt, but use the variable that just worked (`username`):

<!-- TODO Link to commit c00001e -->

```bash
sudo nixos-rebuild switch --flake .
[ -d "~/pictures/screenshots" ] && echo "It's there!" || echo "It's not there"
```

It's there. Hurrah I guess? Why didn't my first approach work?

<!-- TODO Link to commit 4127c3f -->

That still doesn't work, and now if I revert to the previous (working) one it doesn't work either.

<!-- TODO insert confused gif -->

My hunch is that the command only runs when *activating* a generation, and if the configuration isn't changing (I'm changing between A and B, but they were generated a few commits ago now) nix is just switching between them, not _activating_ them? It's a hunch.

Wait. It's back. What did I do? I have a `/home/stooj/pictures/screenshots` directory. Hmm...

I'm going to say that my "hunch" was correct and move on with my life. Maybe that'll bite me somewhere down the road, but that's a future-stoo problem.

```bash
cd ~/code/nix/nix-config
git checkout main
git merge create-directory-for-flameshot
git branch -d create-directory-for-flameshot
```

- [x] Disk partitioning and formatting
- [x] Root user password
- [x] Wireless network connection details for `rentalflat`
- [x] Passwords for `pindy` and `stooj`
- [x] SSH known hosts file maybe.
- [x] `/home/stooj/code/nix/` directory
- [x] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever
- [x] Git user configuration
- [x] GPG pubring
- [x] Create `~/pictures/screenshots`

Woohoo!

# References

- [home.activation](https://nix-community.github.io/home-manager/options.xhtml#opt-home.activation)
- [How to use home.activation to run arbitrary commands? - Help - NixOS Discourse](https://discourse.nixos.org/t/how-to-use-home-activation-to-run-arbitrary-commands/46749)
- [Create a list of directories via Home Manager - Help - NixOS Discourse](https://discourse.nixos.org/t/create-a-list-of-directories-via-home-manager/41255)
- [Nixos-rebuild - NixOS Wiki](https://nixos.wiki/wiki/Nixos-rebuild)
