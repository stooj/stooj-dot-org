Title: Activate Home Manager
Date: 2024-10-11T13:38:59
Category: NixOS

At the end of the OS installation, we had a TODO list of things to do next:

- [x] Switch to flakes
- [ ] User configuration files
- [ ] Secrets
- [ ] More system packages

We also had a list of things to add to the configuration:

- [ ] Disk partitioning and formatting (needs flakes ✓)
- [ ] Root user password (needs secrets ✗)
- [ ] Wireless network connection details for `rentalflat` (needs secrets ✗)
- [ ] Passwords for `pindy` and `stooj` (needs secrets ✗)
- [ ] SSH known hosts file maybe. (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/` directory (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever (needs
      user configuration ✗)

We have a (very) skeleton system with *some* stuff declared in the
configuration, but the rest will need to wait for 
# References
