FontCustom v0.1.3
==========

**Generate custom icon webfonts from the comfort of the command line.**

[Full documentation](http://fontcustom.github.com/fontcustom/)<br/>
[Feedback and issues](https://github.com/FontCustom/fontcustom/issues)


Installation
------------

```sh
# Requires FontForge
brew install fontforge eot-utils ttfautohint
gem install fontcustom
```


Usage
-----

```sh
fontcustom compile path/to/vectors  # Compile icons and css to path/to/fontcustom/*
fontcustom watch path/to/vectors    # Watch for changes
```

Optional second parameter allows you to specify an output directory.

Need help?

```sh
fontcustom --help
```
