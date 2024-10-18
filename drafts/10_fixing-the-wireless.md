Title: Switching the Wireless (or secrets)
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

Ooh, turns out there is a tool that generates the code for us.

# References

- [Declarative wifi configuration - Help - NixOS Discourse](https://discourse.nixos.org/t/declarative-wifi-configuration/1420/3)
- [NixOS Search - Options - networkmanager](https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.profiles&from=0&size=50&sort=relevance&type=packages&query=networkmanager)
- [Janik-Haag/nm2nix: Converts .nmconnection files into nix code](https://github.com/janik-haag/nm2nix)
