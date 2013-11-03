## 1.2.0 (11/2/2013)

* Preparation for fixed glyph code points.
  * Tweaks command line options (more semantic aliases)
  * Renames :data_cache to :manifest
* Sets the stage for a more streamlined, predictable workflow
  * Drops EPS support (was buggy and unused)
  * Turns glyph width adjustment into an option (off by default) ([#137](https://github.com/FontCustom/fontcustom/pull/137)
* Relaxes all dependency version requirements ([#127](https://github.com/FontCustom/fontcustom/issues/127)

## 1.1.1 (10/16/2013)

* Preview characters are turned off by default in the preview template.
* Relaxes JSON version requirement ([#125](https://github.com/FontCustom/fontcustom/pull/125))
* Fixes ttf hinting ([#124](https://github.com/FontCustom/fontcustom/pull/124))
* Cleans up README, fontcustom.yml template, .gitignore ([#123](https://github.com/FontCustom/fontcustom/pull/123), [#128](https://github.com/FontCustom/fontcustom/pull/128))

## 1.1.0 (9/22/2013)

More customizable interface for vastly improved workflow.

* Specify where input vectors/templates are stored ([#89](https://github.com/FontCustom/fontcustom/issues/89))
* Specify where output fonts/templates are saved ([#89](https://github.com/FontCustom/fontcustom/issues/89))
* Stock templates are saved as `#{font_name}.css` instead of `_fontcustom.css`
* More robust path handling (relative paths, customizable `project_root`)
* User-friendly variables for usage in custom templates
* Rails-friendly template
* Enable HTML data-attributes usage ([#118](https://github.com/FontCustom/fontcustom/pull/118))
* Helper characters in preview ([#107](https://github.com/FontCustom/fontcustom/pull/107))
* More robust execution of fontforge command ([#114](https://github.com/FontCustom/fontcustom/pull/114))
* Allow captial letters in font names ([#92](https://github.com/FontCustom/fontcustom/issues/92))
* More helpful, colorful messages
* More intuitive flags (`--verbose=false` => `--quiet`, `--file-hash=false` => `--no-hash`)
* More intuitive version (`fontcustom version` => `fontcustom --version`) ([#115](https://github.com/FontCustom/fontcustom/issues/115))

## 1.0.1 (7/21/2013)

Various bugfixes.

* Set glyph widths automatically ([#95](https://github.com/FontCustom/fontcustom/issues/95))
* Fixes Ruby 1.8.7 syntax error ([#94](https://github.com/FontCustom/fontcustom/issues/94))
* More robust fontforge error handling ([#99](https://github.com/FontCustom/fontcustom/issues/99))

## 1.0.0 (4/18/2013)

Big changes, more flexibility, better workflow. Be sure to check out the [docs](http://fontcustom.com) to see how it all ties together.

* Improved preview html to show glyphs at various sizes
* Added support for fontcustom.yml config file ([#49](https://github.com/FontCustom/fontcustom/issues/49))
* Added support for .fontcustom-data file ([#55](https://github.com/FontCustom/fontcustom/pull/55))
* Added support for custom templates ([#39](https://github.com/FontCustom/fontcustom/pull/39), [#48](https://github.com/FontCustom/fontcustom/issues/48))
* Added support for custom CSS selector namespaces ([#32](https://github.com/FontCustom/fontcustom/issues/32))
* Added support for --verbose=false ([#54](https://github.com/FontCustom/fontcustom/pull/54))
* Improved ascent/decent heights ([#33](https://github.com/FontCustom/fontcustom/issues/33))
* Added clean Ruby API ([#62](https://github.com/FontCustom/fontcustom/issues/62))
* Workaround for Sprockets compatibility ([#61](https://github.com/FontCustom/fontcustom/pull/61))
* Added clean (bootstrap free) CSS and made it the default choice ([#59](https://github.com/FontCustom/fontcustom/pull/59))
* Added option to pass different path to @font-face for SCSS partials ([#64](https://github.com/FontCustom/fontcustom/issues/64))
* Addes SCSS versions of Bootstrap and IE7 stylesheets
* Fixed CSS bug on IE8 and IE9's compatibility mode
* Fixed gem bug where watcher could fall into an infinite loop
* Added error messages for faulty input
* Refactored gem internals to use Thor more sanely
* Refactored tests

## 0.1.4 (2/19/2013)

* Instructions for stopping watcher ([#46](https://github.com/FontCustom/fontcustom/issues/46))
* Dev/contribution instructions ([#45](https://github.com/FontCustom/fontcustom/issues/45))

## 0.1.3 (2/2/2013)

* Add --debug CLI option, which shows fontforge output ([#37](https://github.com/FontCustom/fontcustom/issues/37))
* Patch for Illustrator CS6 SVG output ([#42](https://github.com/FontCustom/fontcustom/pull/42))
* Generate IE7 stylesheet ([#43](https://github.com/FontCustom/fontcustom/pull/43))
* Option to set custom font path for @font-face ([#43](https://github.com/FontCustom/fontcustom/pull/43))
* Option to generate test HTML file showing all glyphs ([#43](https://github.com/FontCustom/fontcustom/pull/43))
* Use eotlite.py instead of mkeot ([#43](https://github.com/FontCustom/fontcustom/pull/43))

## 0.1.0 (12/2/2012)

* Changed API to use Thor `class_option`s
* Added option to change the name of the font and generated files ([#6](https://github.com/FontCustom/fontcustom/issues/6))
* Added option to disable the file name hash ([#13](https://github.com/FontCustom/fontcustom/issues/13))
* `fontcustom watch` compiles automatically on the first run
* Better help messages

## 0.0.2 (11/26/2012)

* Fixed gemspec dependency bug ([#2](https://github.com/FontCustom/fontcustom/pull/2))
* Fixed Windows Chrome PUA bug ([#1](https://github.com/FontCustom/fontcustom/issues/1))
