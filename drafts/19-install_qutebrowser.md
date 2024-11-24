Title: Install qutebrowser
Date: 2024-11-24T08:57:10
Category: NixOS

The final piece of cutting my reliance on `proteus` is getting a browser into `drummer`. I'm going to end up with multiple installed, but my favourite browser and the one I've been using for this blog is [qutebrowser](https://qutebrowser.org/).

## Pros

- It uses vim keybindings
- It has a python API that makes it easy to write little ad-hoc extensions of your own
- You can get it to shell out media files to external handlers (videos -> mpv for example ❤️)
- There's a (quite successful) built-in adblocker
- It has really good session handling
- Configurable with home-manager
- It uses vim keybindings

## Cons

- It uses vim keybindings, so it's not for everyone (but it is for me)
- It uses QTWebEngine (WebKit) which is kinda Blink which is not Gecko so it's part of the web rendering monopoly. (Still no sign of [Servo](https://servo.org/) being ready yet)
- The session handling is a bit fiddly and you can accidentally overwrite a session easily (I've got a fix for this in a future post)
- There's no profile support out of the box (I've got a fix for this in a future post)

## Setup

Pretty easy to install.

<!-- TODO Link to commit b03fa73 -->

I **love** the keybindings in qutebrowser. The [defaults](https://github.com/qutebrowser/qutebrowser/blob/2ba07fe4905fa4399a6325d5822352416a47f64c/qutebrowser/config/configdata.yml#L3743) have binds for yanking (copying) a markdown-formatted link (`[title](url)`). These keybindings are magical and every browser should support this out of the box, and I use other documentation formats as well as markdown so I added my own:

<!-- TODO Link to commit 5243363 -->

If I press `yv`, it yanks (copies to the clipboard) the current title and link in vimwiki. If I use `yr`, it'll yank a restructuredText/Sphinx formatted link. Just magic.

Because qutebrowser is all keyboard driven, I like having quick ways to search for specific things. My default search engine at the moment is [duckduckgo](https://duckduckgo.com/), but it might change to [kagi](https://kagi.com) soon if I can figure out how to script the authentication part.

<!-- TODO Link to commit 803221d -->

So if I want a man page for something, I type `o man something`. Arch wiki page for gdisk in a new tab? `O archwiki gdisk`.

There's plenty more qutebrowser configuration to do later, but this is a pretty decent starting point. Time to merge:

```bash
git checkout main
git merge qutebrowser
git push --all
```

# References

- [programs.qutebrowser](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.qutebrowser.enable)
- [qutebrowser/qutebrowser · config/configdata.yml line 3743](https://github.com/qutebrowser/qutebrowser/blob/2ba07fe4905fa4399a6325d5822352416a47f64c/qutebrowser/config/configdata.yml#L3743)
- [Frequently asked questions | qutebrowser](https://qutebrowser.org/doc/faq.html)
