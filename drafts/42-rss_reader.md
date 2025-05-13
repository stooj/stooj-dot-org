Title: An RSS reader
Date: 2025-05-13T08:39:00
Category: NixOS

```bash
cd ~/code/nix/nix-config
git checkout -b rss-reader
```

One of the advantages of a modern computation device is the ability to browse the world wide web. I like atom and rss feeds, personally. It's another little technical battle that I'll inevitably lose, but I can enjoy them while they still exist.

I just want something that I know and love, so I'm not going to cast around for a bunch of alternatives and then settle for same one anyway. I'm using [newsboat](https://newsboat.org/). There's [newsraft](https://codeberg.org/newsraft/newsraft) as well which is worth investigating some day.

But newsboat is fully support in home-manager, so that makes it an easy choice.

<!-- TODO Link to commit 402a6b8 -->

And turn on newsboat:

<!-- TODO Link to commit dc081c2 -->

I want newsboat to automatically reload the feeds while it's running.

<!-- TODO Link to commit 372ed96 -->

The default reload time of 60 minutes is a little slow for me, so setting it to every half an hour:

<!-- TODO Link to commit de11f80 -->

I'd like vi keybindings please. Luckily there are [plenty](https://moparx.com/configs/newsbeuter/) of [examples](https://forums.freebsd.org/threads/newsboat-rss-reader-enable-vim-key-bindings.69448/) on the [internet](https://gist.github.com/anonymous/42d2f5956e7bc8ee1ebc) to crib from. Although I just noticed that Moparx doesn't use vi binds.

<!-- TODO Link to commit 523b823 -->

Enough configuration for a minute, I can't test this if there isn't a _feed_ to parse.

Since I'm in neorg mode, `@vhyrro` has the (dubious) honour of being my first rss feed item!

<!-- TODO Link to commit 963dad7 -->

<!-- TODO Insert image 42-newsboat_vhyrro_feed.png
-->

I'm not super-wild about the colours, but that's a problem for another day.

I wonder if I can add a query in the url configuration 🤔

<!-- TODO Link to commit 5f05957 -->

<!-- TODO Insert image 42-broken_query.png -->

No. That didn't work. Maybe it's because of the [lack of quotes](https://newsboat.org/releases/2.39/docs/newsboat.html#_query_feeds)?

<!-- TODO Link to commit 3b35cd1 -->

Hey! That looks a lot better!

<!-- TODO Insert image 42-still_broken_query.png -->

Still not quite right. [age](https://newsboat.org/releases/2.39/docs/newsboat.html#attr-age) is definitely a valid filter, so I suppose newsboat is just choking on that first quotation mark.

What if I wrap the whole query in quotes?

<!-- TODO Link to commit 72cf894 -->

```bash
$ cat ~/.config/newsboat/urls
```

```
https://vhyrro.github.io/rss.xml "lua" "neovim" "neorg" "lux" "luarocks" "development" "~Vhyrro's Digital Garden"
"query:ThisMonth:age < 31"
```

Looking good...

<!-- TODO Insert image 42-working_query.png -->

Haha! It works 😁

Since everything wrapped in quotes, let's turn that query name into two words.

<!-- TODO Link to commit 777fd83 -->

And add another query for _really_ new things:

<!-- TODO Link to commit 335b949 -->

That quote escaping is kinda ugly though; I wonder if I can clean it up with using nix's other string deliniator?

<!-- TODO Link to commit 6c8af13 -->

Cool, that worked and I prefer it. Fix the other one too.

<!-- TODO Link to commit 5740082 -->

The obvious choice at the moment for a browser is qutebrowser, but I think it would be quite nice to stay inside a terminal if I possibly can. I'm going to give elinks a go.

Install it first:

<!-- TODO Link to commit ec37c18 -->

And configure newsboat to use it.

<!-- TODO Link to commit 27524c2 -->

<!-- TODO Insert image 42-elinks_default.png -->

Well, that's a little... ugly.

Section 3.8, paragraph 3 of the [manual](http://elinks.cz/documentation/manual.html):

> you must set the `TERM` environment variable to `xterm-256color`.

<!-- TODO Link to commit 5991531 -->

Did not like that:

```
Starting Newsboat 2.37.0...
Loading configuration...Error while processing command `browser TERM=xterm-256color "/nix/store/0hg39pvwzkh1ba7i61bk1yq65448bjcf-elinks-0.17.1.1/bin/elinks"' (/home/stooj/.config/newsboat/config line 20): too many parameters.
```

Try fixing the quotes:

<!-- TODO Link to commit a975b89 -->

That did it.

OK, I need to explore elinks some more and adjust the bindings and colours.

Meanwhile, back in newsboat I'll throw in a comment line to group the configuration for when I add more stuff.

<!-- TODO Link to commit f932b5a -->

And newsboat has macros, which are prefixed with a `macro-prefix`. Sounds a lot like a `leader` key, huh? Time to set it to be the same thing, if the configuration understands a space...

<!-- TODO Link to commit 63a4b87 -->

Nope, that's now how you set the `macro-prefix`. It's a `bind-key` operation.

<!-- TODO Link to commit a03124c -->

I _believe_ that worked? Let's make a macro to test it.

<!-- TODO Link to commit a0c65dd -->

That did _not_ work, pressing `q` just quits newsboat. That probably means the macro key bind isn't working. As a test, I can get rid of that bind and see if `,q` works (`,` is the default `macro-prefix`).

<!-- TODO Link to commit e78d3e4 -->

Hmm, so `<space>` isn't an option for the ~`leader`~ `macro-prefix` key. What about the _`localleader`_?

<!-- TODO Link to commit 506da01 -->

Ah, that works just fine.

Yay! We did it!

# References

- [Newsboat, an RSS reader](https://newsboat.org/)
- [newsraft/newsraft: feed reader for terminal - Codeberg.org](https://codeberg.org/newsraft/newsraft)
- [`programs.newsboat.enable` - Appendix A. Home Manager Configuration Options](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.newsboat.enable)
- [Newsboat rss reader enable vim key bindings | The FreeBSD Forums](https://forums.freebsd.org/threads/newsboat-rss-reader-enable-vim-key-bindings.69448/)
- [moparx's ~/.newsbeuter/config](https://moparx.com/configs/newsbeuter/)
- [newsboat config - gist:42d2f5956e7bc8ee1ebc](https://gist.github.com/anonymous/42d2f5956e7bc8ee1ebc)
- [Query feeds - The Newsboat RSS Feedreader](https://newsboat.org/releases/2.39/docs/newsboat.html#_query_feeds)
- [Filter language - The Newsboat RSS Feedreader](https://newsboat.org/releases/2.39/docs/newsboat.html#_filter_language)
- [ELinks - Full-Featured Text WWW Browser](http://elinks.cz/)
- [The ELinks Manual](http://elinks.cz/documentation/manual.html)
- [Howto: Use elinks like a pro | Motho ke motho ka botho](https://kmandla.wordpress.com/2007/05/06/howto-use-elinks-like-a-pro/)
