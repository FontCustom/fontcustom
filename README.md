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
brew install fontforge eot-utils ttfautohint
gem install fontcustom

# On Linux
sudo apt-get install fontforge ttfautohint
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
`fontcustom config`. This should live in the directory where you plan on
running `fontcustom` commands. Most of the following can also be used as
command line flags (`--css-selector`, etc.).

```yml
# (defaults shown)
font_name: fontcustom                 # Names the font and sets the name and directory
                                      # of generated files
project_root: (pwd)                   # Context for all relative paths
input: (project_root)                 # Where vectors and templates are located
output: (project_root)/(font name)    # Where generated files will be saved
config: (pwd)/fontcustom.yml          # Optional path to a configuration file
templates: [ css, preview ]           # Templates to generate alongside fonts
                                      # Possible values: preview, css, scss, scss-rails
css_selector: .icon-{{glyph}}         # Template for CSS classes
                                      6
preprocessor_path: ""                 # Font path used in proprocessor templates (Sass, etc.)
no_hash: false                        # Don't add asset-busting hashes to font files
autowidth: false                      # Automatically size glyphs based on the width of
                                      # their individual vectors
debug: false                          # Output raw messages from fontforge
quiet: false                          # Silence all messages except errors

# For more control over file locations,
# set input and output as Yaml hashes
input:
  vectors: path/to/vectors            # required
  templates: path/to/templates

output:
  fonts: app/assets/fonts             # required
  css: app/assets/stylesheets
  preview: app/views/styleguide
  6
```

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
