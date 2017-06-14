[![Gem Version](https://badge.fury.io/rb/fontcustom.png)](http://badge.fury.io/rb/fontcustom)
[![Build Status](https://api.travis-ci.org/FontCustom/fontcustom.png)](https://travis-ci.org/FontCustom/fontcustom)
[![Code Quality](https://codeclimate.com/github/FontCustom/fontcustom.png)](https://codeclimate.com/github/FontCustom/fontcustom) [![Bountysource](https://www.bountysource.com/badge/tracker?tracker_id=32953)](https://www.bountysource.com/trackers/32953-endtwist-fontcustom?utm_source=32953&utm_medium=shield&utm_campaign=TRACKER_BADGE)

## Font Custom

**Icon fonts from the command line.**

Generate cross-browser icon fonts and supporting files (@font-face CSS, etc.)
from a collection of SVGs
([example](https://rawgit.com/FontCustom/fontcustom/master/spec/fixtures/example/example-preview.html)).

[Changelog](https://github.com/FontCustom/fontcustom/blob/master/CHANGELOG.md)<br>
[Bugs/Support](https://github.com/FontCustom/fontcustom/issues)<br>
[Contribute!](https://github.com/FontCustom/fontcustom/blob/master/CONTRIBUTING.md)

### Installation

Requires **Ruby 1.9.3+**, **WOFF2**, **FontForge** with Python scripting.

```sh
# On Mac
brew tap bramstein/webfonttools
brew update
brew install woff2

brew install fontforge --with-python
brew install eot-utils
gem install fontcustom

# On Linux
sudo apt-get install zlib1g-dev fontforge
wget http://people.mozilla.com/~jkew/woff/woff-code-latest.zip
unzip woff-code-latest.zip -d sfnt2woff && cd sfnt2woff && make && sudo mv sfnt2woff /usr/local/bin/
git clone --recursive https://github.com/google/woff2.git && cd woff2 && make clean all && sudo mv woff2_compress /usr/local/bin/ && sudo mv woff2_decompress /usr/local/bin/
gem install fontcustom
```
####Note for windows:

1. Install fontforge:  http://fontforge.github.io/en-US/downloads/windows/
-  Install to a path without spaces, eg c:\FontForgeBuilds
-  At the end of the installer check the 'run fontforge' box. It finishes some set up.
2. Add the installation path to your System PATH variable (c:\FontForgeBuilds\bin)
3. Open up a new command prompt and test it. `fontforge -help`
4. gem install fontcustom


### Quick Start

```sh
fontcustom compile my/vectors  # Compiles icons into `fontcustom/`
fontcustom watch my/vectors    # Compiles when vectors are changed/added/removed
fontcustom compile             # Uses options from `./fontcustom.yml` or `config/fontcustom.yml`
fontcustom config              # Generate a blank a config file
fontcustom help                # See all options
```

### Configuration

To manage settings between compiles, run `fontcustom config` to generate a
config file. Inside, you'll find a list of [**all possible options**](https://github.com/FontCustom/fontcustom/blob/master/lib/fontcustom/templates/fontcustom.yml).
Each option is also available as a dash-case command line flag (e.g.
`--css-selector`) that overrides the config file.

### SVG Guidelines

* All colors will be rendered identically. Watch out for white fills!
* Use only solid colors. SVGs with transparency will be skipped.
* For greater precision in curved icons, use fills instead strokes and [try
  these solutions](https://github.com/FontCustom/fontcustom/issues/85).
* Activating `autowidth` trims horizontal white space from each glyph. This
  can be much easier than centering dozens of SVGs by hand.

### Advanced

**For use with Compass and/or Rails**

Set `templates` to include `scss-rails` to generate a SCSS partial with the
compatible font-url() helper. You'll most likely also need to set
`preprocessor_path` as the relative path from your compiled CSS to your output
directory.

**Example Use in Rails**

Add `gem 'fontcustom'` to your gem file.
```
bundle
```
Create a `fontcustom.yml` file with something like this:
```yml
# config/fontcustom.yml

font_name: icons
css_selector: .icon-{{glyph}}
preprocessor_path: ""
autowidth: false
no_hash: true
force: false
debug: false
quiet: false

input:
  vectors: app/assets/icons

output:
  fonts: app/assets/fonts
  css: app/assets/stylesheets

templates:
 - scss
```

This tells the gem to take the vectors from `app/assets/icons` and create fonts and stylesheets for them.

Create a file in lib/tasks called `icons.rake` :

```ruby
namespace :icons do
  task :compile do
    puts "Compiling icons..."
    puts %x(fontcustom compile)
  end
end
```

Load up the icons directory and test it out.

Run this command with
```sh
rake icons:compile
```

This should run the installed and configured gem to create your icons:

```sh
Compiling icons...
      create  .fontcustom-manifest.json
      create  app/assets/fonts
      create  app/assets/fonts/icons.ttf
              app/assets/fonts/icons.svg
              app/assets/fonts/icons.woff
              app/assets/fonts/icons.eot
      create  app/assets/stylesheets/_icons.scss
```
Access these new icons by creating a tag with the class `icon-{{glyph}}` where the {{glyph}} is the name of the svg you put in the icon folder.
For example, if you added a file called 'cars54' icon would look something like this:

```html
<i class="icon-cars54"</i>
```

Now the font is adjustable to css 'font-size' and 'color'.

**Save CSS and fonts to different locations**

You can save generated fonts, CSS, and other files to different locations by
using `fontcustom.yml`. Font Custom can also read input vectors and templates
from different places.

Just edit the `input` and `output` YAML hashes and their corresponding keys.

**Tweak font settings**

By default, Font Custom assumes a square viewBox, 512 by 512, and 16 pica
points. Change `font_design_size`, `font_em`, `font_ascent`, `font_descent`,
and `autowidth` to suit your own needs.

**Generate LESS, Stylus, and other text files**

Custom templates give you the flexibility to generate just about anything you
want with Font Custom's output data.

Any non-SVG file in your input directory (or input:templates directory if you
set it in `fontcustom.yml`) will be available as a custom template to copy into
the output directory after compilation. You just need to specify the file name
under the `templates` hash.

Any embedded ruby in the templates will be processed, along with the following
helpers:

* `font_name`
* `font_face`: [FontSpring's Bulletproof @Font-Face Syntax](http://www.fontspring.com/blog/further-hardening-of-the-bulletproof-syntax)
* `glyph_selectors`: comma-separated list of all icon CSS selectors
* `glyphs`: all selectors and their codepoint assignments (`.icon-example:before { content: "\f103"; }`)
* `@options`: a hash of options used during compilation
* `@manifest`: a hash of options, generated file paths, code points, and just about everything else Font Custom knows.
* `@font_path`: the path from CSS to font files (without an extension)
* `@font_path_alt`: if `preprocessor_path` was set, this is the modified path
* `pseudo_element`: if `css3` was set to true, then it will print `::before`. Otherwise the PseudoElement will be `:before`

`font_face` accepts a hash that modifies the CSS url() function and the path of
the font files (`font_face(url: "font-url", path: @font_path_alt)`).

---

[Licenses](https://github.com/FontCustom/fontcustom/blob/master/LICENSES.txt)

Brought to you by [@endtwist](https://github.com/endtwist) and [@kaizau](https://github.com/kaizau)
