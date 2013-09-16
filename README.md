# FontCustom v1.1.0

**Generate icon webfonts from the comfort of the command line.**

[Full documentation](http://fontcustom.com)<br/>
[Changelog](https://github.com/FontCustom/fontcustom/blob/master/CHANGELOG.md)<br/>
[Feedback and issues](https://github.com/FontCustom/fontcustom/issues)

## Installation

```sh
# Requires FontForge
brew install fontforge eot-utils ttfautohint
gem install fontcustom
```

## Quick Start

```sh
fontcustom compile path/to/vectors  # Compiles icons into `fontcustom/`
fontcustom watch path/to/vectors    # Compiles when vectors are changed/added/removed

fontcustom compile                  # Uses configuration options from `fontcustom.yml`
fontcustom watch                    # or `config/fontcustom.yml`

fontcustom help                     # See all options
```

## Configuration

To avoid finger-fatigue, create a configuration file with `fontcustom config`. Typically, this should live in the directory where you plan on running `fontcustom` commands.

```yml
# Available Options (defaults shown)
font_name: fontcustom                 # Names the font (also sets name and directory of generated files)
project_root: (working dir)           # Context for all relative paths
input: (project_root)                 # Where vectors and templates are located
output: (project_root)/(font name)    # Where generated files will be saved
file_hash: true                       # Include an asset-busting hash
css_prefix: icon-                     # CSS class prefix
preprocessor_path: ""                 # Font path used in CSS proprocessor templates
data_cache: (same as fontcustom.yml)  # Sets location of data file
debug: false                          # Output raw messages from fontforge
verbose: true                         # Set to false to silence
templates: [ css, preview ]           # Templates to generate alongside fonts
                                      # Possible values: preview, css, scss, scss-rails, bootstrap, 
                                      # bootstrap-scss, bootstrap-ie7, bootstrap-ie7-scss

# Advanced input/output
#   Set input or output as a hash for more control
input:
  vectors: path/to/vectors            # required
  templates: path/to/templates

output:
  fonts: app/assets/fonts             # required
  css: app/assets/stylesheets
  preview: app/views/styleguide
  custom-template.yml: custom/path    # set paths of custom templates by referencing their file name
```

---

[Contributor Guidelines](https://github.com/FontCustom/fontcustom/blob/master/CONTRIBUTING.md)<br/>
[Licenses](https://github.com/FontCustom/fontcustom/blob/master/LICENSES.txt)

Brought to you by [@endtwist](https://github.com/endtwist) and [@ezYZ](https://github.com/ezYZ)
