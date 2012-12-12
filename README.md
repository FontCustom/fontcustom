FontCustom v0.1.2
==========

**Generate custom icon webfonts from the comfort of the command line.**

[Full documentation](http://endtwist.github.com/fontcustom/)
[Feedback and issues](https://github.com/endtwist/fontcustom/issues)


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

Optional second parameter allows you to specify an output directory. By default a "fontcustom" directory will be created as a sibling to the input directory.

Creating SVG Files
------------------

* To ensure that all glyphs appear at the same scale, all SVG files should have the same canvas dimensions.
* All glyphs should be solid black.
* All glyphs should be converted to outlines (aka traced)
* Export as SVG 1.1 from Illustrator
