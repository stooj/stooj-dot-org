Title: Switching to flakes
Date: 2024-10-08T07:57:01
Category: NixOS

Well done stoo. You installed NixOS.

<!-- TODO Insert a Y Tho gif -->

<!-- TODO Write why I think NixOS is great -->

## Switching to flakes

Currently all our configuration is in `/etc/nixos/` and it's owned by root. That
makes it very inconvenient for making changes; I'd far rather have it somewhere
in my home directory and then be able to apply it to the system from there.
Oooh, maybe to multiple systems!

To do all that, and make it easier to include other configurations (I don't
want to use channels, it's imperative), I'm going to switch the configuration to
use flakes.

Which are _still_ experimental! They seem to be pretty-universally used at this
point, but you still need to enable them in your configuration.

<!-- TODO Link to commit b8e900b -->

Engage.

```bash
sudo nixos-rebuild switch
```

Now that option is turned on, the next rebuild will look for `flake.nix` first,
and if it can't find it it'll try `configuration.nix`. Cool. We're gonna need a
flake file.

<!-- TODO Link to commit 0b19b83 -->

A flake has inputs and outputs. The only input we have so far for this flake is
nixpkgs 24.05, and the output is a single nixos config for `drummer`. Part of
the output just says "use `configuration.nix`", so while we're using flakes now,
we're still just using everything in `configuration.nix`. A seamless transition.

Time to Make it So and check it worked.

Wow, that took a lot longer this time and actually timed out. I'd to try a
couple of times before it completed. Is _that_ why flakes are still considered
experimental?
Hopefully it'll be quicker next time?

Anyway, the command finished and it generated a lock file; think `go.sum`,
`package-lock.json`, or `poetry.lock`.

<!-- TODO Link to commit ed374a4 -->

Great. All that work to produce... the same as we had before. What was the point
again?

Ahah, I'm glad you asked. Lets move the configuration out of the root-owned
system directory (`/etc/nixos`) and into somewhere belonging to the user.

```bash
mkdir --parents ~/code/nix/nix-config
sudo mv /etc/nixos/* ~/code/nix/nix-config/
sudo chown --recursive stooj:users ~/code/nix/nix-config/
```

All the code r belong to us. Well, me anyway.

Now I can use vim as a regular user instead of needing `sudo`. We can treat the
configuration like any other software project and put it anywhere we want!

Time to check things still work by rebuilding the system. This time we pass the
`--flake` argument with a path to the flake we want to use, which is `.` in this
case (otherwise known as "the directory I'm currently in")

```bash
cd ~/code/nix/nix-config
sudo nixos-rebuild switch --flake .
```

Now we're getting somewhere! This is looking better and better. But we did just
run some imperative commands on my home directory, so it's time to add it to our
TODO list.

#### Things to add to the configuration some day

- [ ] Disk partitioning and formatting
- [ ] Root user password
- [ ] Wireless network connection details for `rentalflat`
- [ ] Passwords for `pindy` and `stooj`
- [ ] SSH known hosts file maybe.
- [ ] `/home/stooj/code/nix/` directory
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever

# References

- [NixOS & Flakes Book | Home Page](https://nixos-and-flakes.thiscute.world/)
- [Nix from First Principles: Flake Edition - Tony Finn](https://tonyfinn.com/blog/nix-from-first-principles-flake-edition/)
