[![Gem Version](https://badge.fury.io/rb/fontcustom.png)](http://badge.fury.io/rb/fontcustom)
[![Build Status](https://api.travis-ci.org/FontCustom/fontcustom.png)](https://travis-ci.org/FontCustom/fontcustom)
[![Code Quality](https://codeclimate.com/github/FontCustom/fontcustom.png)](https://codeclimate.com/github/FontCustom/fontcustom)

## Font Custom

**Icon fonts from the command line.**

Generate cross-browser compatible icon fonts and supporting files (e.g.
@font-face CSS) from a collection of SVGs.

[Documentation](http://fontcustom.com)<br/>
[Changelog](https://github.com/FontCustom/fontcustom/blob/master/CHANGELOG.md)<br/>
[Support](https://github.com/FontCustom/fontcustom/issues)<br/>
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

fontcustom compile                  # Uses configuration options from `fontcustom.yml`
fontcustom watch

fontcustom config                   # Generate a blank a configuration file
fontcustom help                     # See all options
```

### Configuration

To preserve options between compiles, create a configuration file with
`fontcustom config`. This should live in the directory where you plan on
running `fontcustom` commands.

```yml
# General Options (defaults shown)
font_name: fontcustom                 # Names the font and sets the name and directory
                                      # of generated files
project_root: (pwd)                   # Context for all relative paths
input: (project_root)                 # Where vectors and templates are located
output: (project_root)/(font name)    # Where generated files will be saved
config: (pwd)/fontcustom.yml          # Optional path to a configuration file
templates: [ css, preview ]           # Templates to generate alongside fonts
                                      # Possible values: preview, css, scss,
                                      # scss-rails, bootstrap, bootstrap-scss,
                                      # bootstrap-ie7, bootstrap-ie7-scss
css_prefix: icon-                     # CSS class prefix
no_hash: false                        # Don't add asset-busting hashes
preprocessor_path: ""                 # Font path used in CSS proprocessor templates
autowidth: false                      # Automatically size glyphs based on the width of
                                      # their individual vectors
debug: false                          # Output raw messages from fontforge
quiet: false                          # Silence all output messages

# For more control over file locations,
# set input and output as Yaml hashes
input:
  vectors: path/to/vectors            # required
  templates: path/to/templates

output:
  fonts: app/assets/fonts             # required
  css: app/assets/stylesheets
  preview: app/views/styleguide
  custom-template.yml: custom/path
```

### SVG Recommendations

All vectors are imported as a single layer with colors and strokes ignored. If
you run into trouble, try combining your paths and ensuring that you don't have
any white fills (which show up as colored).

By default, Font Custom scales each vector to fit a 512x512 canvas with a
baseline at 448. In practice, that means as long as your SVG `viewBox` is
square, icons will look exactly like your SVGs.

If you set the `autowidth` option, Font Custom will trim the widths of each
glyph to the vector width. Heights are unaffected.

---

[Licenses](https://github.com/FontCustom/fontcustom/blob/master/LICENSES.txt)

Brought to you by [@endtwist](https://github.com/endtwist) and [@ezYZ](https://github.com/ezYZ)
