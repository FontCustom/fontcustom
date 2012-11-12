FontCustom v0.0.1
==========

**Generate custom icon webfonts from the comfort of the command line.**

[Full documentation](http://endtwist.github.com/fontcustom/)
[Feedback and issues](https://github.com/endtwist/fontcustom/issues)


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
fontcustom watch path/to/vectors    # Watch for changes
```

Optional second parameter allows you to specify an output directory.
