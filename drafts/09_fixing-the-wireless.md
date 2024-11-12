Title: Fixing the Wireless
Date: 2024-10-17T20:20:05
Category: NixOS

Where was that list of things to add to the configuration?

- [.] Disk partitioning and formatting
- [ ] Root user password
- [ ] Wireless network connection details for `rentalflat`
- [ ] Passwords for `pindy` and `stooj`
- [ ] SSH known hosts file maybe.
- [ ] `/home/stooj/code/nix/` directory
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever

We've _kinda_ done the first one, but I still want to prod it a little. No
encryption yet. Still, that reinstall was pretty cool.

It'd be nice to include the wireless details as part of our configuration.

There's not a huge amount of information about this, but I think we can work it
out as we go.

First of all, the option we want it `networking.networkmanager.ensureProfiles`

<!-- TODO Link to commit 6f357e3 -->

Oops, the actual profiles will be nested inside a `profiles` option. Add that
too.

<!-- TODO Link to commit 5f2c99b -->

Ooh, turns out there is a [tool that generates the code](https://github.com/janik-haag/nm2nix) for us.

And because this is Nix and flakes, we can run it with a single command:

```bash
sudo su - root
cd /etc/NetworkManager/system-connections && \
    nix --extra-experimental-features 'nix-command flakes' run \
        github:Janik-Haag/nm2nix | \
        nix --extra-experimental-features 'nix-command flakes' run \
        nixpkgs#nixfmt-rfc-style"
```

It's piping the output to nixfmt-rfc-style, which you can optionally skip. My
existing config is definitely not styled yet.

It included the passphrase as part of the configuration, so I'm going to
temporarily change that to something not secret.

<!-- TODO Link to commit 98b1cc3 -->

There's a bunch of extra config included in this section that I don't think we
need either.

It doesn't need to be associated with a specific wireless interface:

<!-- TODO Link to commit 3cb3bfc -->

Pretty sure the connection doesn't need a UUID either:

<!-- TODO Link to commit 9fc82e7 -->

Huh. I guess this is also when you discover that the SSID I'm connecting to
isn't called `rentalflat`. You caught me!

Might as well give the configuration a nicer name at least.

<!-- TODO Link to commit 9fc82e7 -->

Well, that was easy.

Oh, wait. The pre-shared key. 🤔

Enter [sops-nix](https://github.com/Mic92/sops-nix). Next time.

<!-- TODO Add link to next blog post -->

# References

- [Declarative wifi configuration - Help - NixOS Discourse](https://discourse.nixos.org/t/declarative-wifi-configuration/1420/3)
- [NixOS Search - Options - networkmanager](https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.profiles&from=0&size=50&sort=relevance&type=packages&query=networkmanager)
- [Janik-Haag/nm2nix: Converts .nmconnection files into nix code](https://github.com/janik-haag/nm2nix)
