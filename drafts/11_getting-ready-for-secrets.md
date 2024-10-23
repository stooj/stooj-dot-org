Title: Getting ready for secrets
Date: 2024-10-18T18:21:33
Category: NixOS

So far I've tried to minimise the number of dependencies for setting up my
laptop. By dependencies, I mean "things that I already need to have set up in
order to build this brave new... thing"

There are a few things that I have _assumed_ exists in the world:

1. An internet connection (in my case, accessed via wifi)
2. An account on GitHub
3. Oh, and GitHub
4. Pulumi and an account on Pulumi-cloud

There's one other thing that I've sort of brushed over: an SSH keypair. An SSH
keypair is the essential tool for the modern world, and they're easy to make.

But for this next bit we're also going to need a GPG key. Let me explain.

If we're going to store as much as we can as code, we need a way of storing
secret stuff. Passwords. Keys. Maybe some work stuff that I can't publish. We
need a way of encrypting things in the code repo and decrypting them so they get
applied to our target machines (only drummer so far).

The idea is that the target machine has the ability to decrypt the secret, and
it'll be stored somewhere local on that machine.

But the human (me, myself) also needs to be able to encrypt and decrypt those
secrets so I can change them if needed.

I can use a GPG key for the human-side of the equation, and for machine
decrypting, each machine will have a pretty handy keypair to use: SSH keys.
Simple, right?

Well not really - we've just kicked the bucket down the well some more; how do
we securely store the SSH keys and how do make sure they are included as part of
the configuration for the machine?

How do we manage the GPG keys securely?

It's time to add a couple more dependencies to my list, and they are big ones!

1. A Yubikey configured with a GPG key (and use it for SSH)
2. A [pass](https://www.passwordstore.org/) store that is hosted somewhere (private)

The idea is that your yubikey is the essential first step of
bootstrapping/maintaining the environment. It has the key that can decrypt the
contents of your `pass` store, and the `pass` store will contain the SSH keys
for the target machines.

To set up a YubiKey (and I thoroughly recommend this as a way to carry your GPG
and SSH keys around), you can't do any better than to follow the excellent guide
by drduh: [YubiKey-Guide | Guide to using YubiKey for GnuPG and SSH](http://drduh.github.io/YubiKey-Guide/).

That guide exhaustively walks through *every* **single** ***step***, and since
I've done it (a couple of times now) I'm going to assume it's been done going
forward.

Once you've got a YubiKey set up, getting a [pass store](https://www.passwordstore.org/) is a breeze.

Once all that's done, we're ready to store secrets in our configuration.


Enter [sops-nix](https://github.com/Mic92/sops-nix).

It's a way to keep secrets in your Nix config.
And [sops](https://github.com/getsops/sops#2usage) Secrets OPerationS is a tool for managing secrets.

[^NOTE]: Sops can use different backends, it'd be cool if it could use ESC.

# References

- [YubiKey-Guide | Guide to using YubiKey for GnuPG and SSH](http://drduh.github.io/YubiKey-Guide/)
- [Pass: The Standard Unix Password Manager](https://www.passwordstore.org/)
- [Mic92/sops-nix: Atomic secret provisioning for NixOS based on sops](https://github.com/Mic92/sops-nix)
- [getsops/sops: Simple and flexible tool for managing secrets](https://github.com/getsops/sops#2usage)
