[![Gem Version](https://badge.fury.io/rb/fontcustom.png)](http://badge.fury.io/rb/fontcustom)
[![Build Status](https://api.travis-ci.org/FontCustom/fontcustom.png)](https://travis-ci.org/FontCustom/fontcustom)
[![Code Quality](https://codeclimate.com/github/FontCustom/fontcustom.png)](https://codeclimate.com/github/FontCustom/fontcustom)

## Font Custom

**Icon fonts from the command line.**

Generate cross-browser icon fonts and supporting files (@font-face CSS, etc.) from a collection of SVGs.

[Changelog](https://github.com/FontCustom/fontcustom/blob/master/CHANGELOG.md)<br>
[Bugs/Support](https://github.com/FontCustom/fontcustom/issues)<br>
[Contribute!](https://github.com/FontCustom/fontcustom/blob/master/CONTRIBUTING.md)

### Installation

Requires **Ruby 1.9.2+**, **FontForge** with Python scripting.

```sh
# On Mac
brew install fontforge eot-utils
gem install fontcustom

# On Linux
sudo apt-get install fontforge
wget http://people.mozilla.com/~jkew/woff/woff-code-latest.zip
unzip woff-code-latest.zip -d sfnt2woff && cd sfnt2woff && make && sudo mv sfnt2woff /usr/local/bin/
gem install fontcustom
```

### Quick Start

```sh
fontcustom compile path/to/vectors  # Compiles icons into `fontcustom/`
fontcustom watch path/to/vectors    # Compiles when vectors are changed/added/removed
fontcustom compile                  # Uses configuration file at `fontcustom.yml`
                                    # or `config/fontcustom.yml`
fontcustom config                   # Generate a blank a configuration file
fontcustom help                     # See all options
```

### Configuration

To preserve options between compiles, create a configuration file with
`fontcustom config`. This should live in the directory where you run
all `fontcustom` commands. Each of the following has its own command 
line flag (`--css-selector`, etc.). Defaults values are shown.

**Basics**

```yml
project_root: (pwd)                   # Context for all relative paths
input: (project_root)                 # Where vectors and templates are located
output: (project_root)/(font name)    # Where generated files will be saved
config: (pwd)/fontcustom.yml          # Optional path to a configuration file
debug: false                          # Output raw messages from fontforge
quiet: false                          # Silence all messages except errors

# For more control over file locations, set
# input and output as hashes instead of strings
input:
  vectors: path/to/vectors            # required
  templates: path/to/templates

output:
  fonts: app/assets/fonts             # required
  css: app/assets/stylesheets
  preview: app/views/styleguide
```

**Fonts**

```yml
font_name: fontcustom                 # Also sets the default output directory and
                                      # the name of generated stock templates
no_hash: false                        # Don't add asset-busting hashes to font files
autowidth: false                      # Automatically size glyphs based on the width of
                                      # their individual vectors
```

**Templates**

```yml
templates: [ css, preview ]           # List of templates to generate alongside fonts
                                      # Possible values: preview, css, scss, scss-rails
css_selector: .icon-{{glyph}}         # CSS selector format (`{{glyph}}` is replaced)
preprocessor_path: ""                 # Font path used in CSS proprocessor templates
                                      # Set to "" or false to use the bare font name

# Custom templates should live in the `input` 
# or `input[:templates]` directory and be added
# to `templates` as their basename:
templates: [ preview, VectorIcons.less ]
```

Custom templates have access to `@options`, `@manifest`, and the following ERB helpers:

* `font_name` 
* `font_face`: FontSpring's [Bulletproof @font-face syntax](http://www.fontspring.com/blog/further-hardening-of-the-bulletproof-syntax)
* `glyph_selectors`: comma-separated list of all selectors
* `glyphs`: all selectors and their codepoint assignments (`.icon-example:before { content: "\f103"; }`)

### SVG Guidelines

* All colors will be rendered identically — including white fills.
* Make transparent colors solid. SVGs with transparency will be skipped.
* For greater precision, prefer fills to strokes (especially if your icon includes curves).
* Keep your icon within a square `viewBox`. Font Custom scales each SVG to fit
  a 512x512 canvas with a baseline at 448.
* Setting `autowidth` to true trims horizontal white space from each glyph. This can be much easier
  than centering dozens of SVGs by hand.

---

[Licenses](https://github.com/FontCustom/fontcustom/blob/master/LICENSES.txt)

Brought to you by [@endtwist](https://github.com/endtwist) and [@ezYZ](https://github.com/ezYZ)
