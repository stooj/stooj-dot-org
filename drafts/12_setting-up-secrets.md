Title: Setting up secrets
Date: 2024-10-23T14:18:11
Category: NixOS

Enter [sops-nix](https://github.com/Mic92/sops-nix).

It's a way to keep secrets in your Nix config.
And [sops](https://github.com/getsops/sops#2usage) Secrets OPerationS is a tool for managing secrets.

[^NOTE]: Sops can use different backends, it'd be cool if it could use ESC.
Sops-nix can only use `age` and `GPG` though[^1]. 🙁


[^1]: [feature request: support for external key management · Issue #629 · Mic92/sops-nix](https://github.com/Mic92/sops-nix/issues/629)

# References

- [Mic92/sops-nix: Atomic secret provisioning for NixOS based on sops](https://github.com/Mic92/sops-nix)
- [getsops/sops: Simple and flexible tool for managing secrets](https://github.com/getsops/sops#2usage)
- [feature request: support for external key management · Issue #629 · Mic92/sops-nix](https://github.com/Mic92/sops-nix/issues/629)
