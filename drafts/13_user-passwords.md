Title: User passwords
Date: 2024-11-11T22:22:42
Category: NixOS

Here's the TODO list for things that need to be put into code:

- [x] Disk partitioning and formatting (needs flakes ✓)
- [ ] Root user password (needs secrets ✓)
- [x] Wireless network connection details for `rentalflat` (needs secrets ✗)
- [ ] Passwords for `pindy` and `stooj` (needs secrets ✗)
- [ ] SSH known hosts file maybe. (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/` directory (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever (needs
      user configuration ✗)
- [ ] Git user configuration (needs user configuration ✗)
- [ ] GPG pubring

Now that I have secrets, user passwords shouldn't be hard. While you can just
hard-code the user's password in the configuration using
[`users.users.<name>.password`](https://search.nixos.org/options?channel=unstable&show=users.users.%3Cname%3E.password),
it's a bad idea. The docs even tell you not to. And remember that you can't just
inject secrets into the nix configuration (because they aren't actually known at
compilation time). Nix people have thought of this though and included the
[`hashedPasswordFile`](https://search.nixos.org/options?channel=unstable&show=users.users.%3Cname%3E.hashedPasswordFile) option, which will go beautifully with sops-nix.

## Root user first

To do this I need:

1. The root password for `drummer`
2. The hash of the root password for `drummer`
3. A way to get it into the `secrets.yaml` file (I can't just append the
   password to the last line of the encrypted file, that'll break sops)

So I'm going to slightly cheat here and do it over the network. I don't know a
way of copying and pasting things on drummer yet, since there's nothing but a
tty there.

So here are the steps I've taken:

1. Plug my yubikey into `proteus`
2. Run `mkpasswd` on `proteus`, using the password stored in my password store:
    ```bash
    mkpasswd $(pass machines/drummer/root)
    ```
3. Copy the result to a clipboard (I use tmux btw)
4. SSH into `drummer`
5. Disconnect my yubikey from `proteus` and plug it into `drummer`
6. In my SSH session to `drummer`, run the sops command:
    ```bash
    nix-shell --packages sops --run "sops secrets.yaml"
    ```
7. Add the root password to the secrets list. Something like:
    ```
    rootPasswordHash: <CONTENT OF CLIPBOARD>
    ```
    
<!-- TODO Link to commit 6b039f9 -->
 
Time to add the secret to the configuration.

<!-- TODO Link to commit b2f1d00 -->

This will create `rootPasswordHash` as a file in `/run/secrets`

But there's a bit of a race condition for user passwords and sops-nix, since
NixOS wants to create the users before sops-nix has a chance to run. You can get
around it by declaring that the secret is `neededForUsers`. This will do
something that I don't quite understand but it'll be available when NixOS
creates the users.

<!-- TODO Link to commit 6d4b51b -->

This will move the secret from `/run/secrets` to `/run/secrets-for-users`.

And finally, set the `hashedPasswordFile` for the `root` user:

<!-- TODO Link to commit 59ba3ce -->

- [x] Disk partitioning and formatting (needs flakes ✓)
- [x] Root user password (needs secrets ✓)
- [x] Wireless network connection details for `rentalflat` (needs secrets ✗)
- [ ] Passwords for `pindy` and `stooj` (needs secrets ✗)
- [ ] SSH known hosts file maybe. (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/` directory (needs user configuration ✗)
- [ ] `/home/stooj/code/nix/nix-config` cloned from GitHab or whatever (needs
      user configuration ✗)
- [ ] Git user configuration (needs user configuration ✗)
- [ ] GPG pubring

Woohoo!

## References

- [NixOS Search - Options - users.users.<name>.password](https://search.nixos.org/options?channel=unstable&show=users.users.%3Cname%3E.password)
- [NixOS Search - Options - users.users.<name>.hashedPasswordFile](https://search.nixos.org/options?channel=unstable&show=users.users.%3Cname%3E.hashedPasswordFile)
- [Get the short hash of a commit](https://stackoverflow.com/a/37352791)
- [Mic92/sops-nix: Setting a user's password](https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password)
