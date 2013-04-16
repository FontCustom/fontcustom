# FontCustom v1.0.0

**Generate custom icon webfonts from the comfort of the command line.**

[Full documentation](http://fontcustom.com)<br/>
[Feedback and issues](https://github.com/FontCustom/fontcustom/issues)

## Installation

```sh
# Requires FontForge
brew install fontforge eot-utils ttfautohint
gem install fontcustom
```

## Quick Start

```sh
fontcustom compile path/to/vectors                  # Compiles into `fontcustom`
fontcustom compile path/to/vectors -o assets/fonts  # Compiles into `assets/fonts`
fontcustom watch path/to/vectors -t=scss preview    # Compiles when changes to vectors are dectected
                                                    # and includes a scss partial and glyph preview

fontcustom help                                     # to see all options
```

## Config

To avoid finger-fatigue, include a fontcustom.yml configuration file with your vectors:

```sh
fontcustom config path/to/vectors   # Creates annotated config file
vim path/to/vectors/fontcustom.yml 
```
