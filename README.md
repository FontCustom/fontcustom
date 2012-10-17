FontCustom
==========

(Pre-release)

__Automated glyph font generator. Stop building glyph fonts by hand and FontCustom-ize.__


Installation
------------

```sh
# Requires FontForge
brew install fontforge
gem install fontcustom
```


Usage
-----

```sh
fontcustom compile path/to/vectors  # Compile icons and css to path/to/fontcustom/*
fontcustom watch path/to/vectors    # Listen for changes
```

Options second parameter allows you to specify an output directory.

TODO
----

* Watcher should clean up old files (ideally without adding any dotfiles to preserve state)
* Cleaner thor messages (avoid extra dir exists messages)
* Less awkward tests
