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
