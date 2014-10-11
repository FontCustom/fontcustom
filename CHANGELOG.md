## 1.3.4 (10/11/2014)

* Updates rspec tests to be compatible with rspec v3.1.6
* Add additional metrics to make it easier to have different size icon fonts ([#175](https://github.com/FontCustom/fontcustom/pull/175))
* Add woff data uri to generated CSS + template helper ([#182](https://github.com/FontCustom/fontcustom/pull/182))
* Support listen v1 and v2 ([#191](https://github.com/FontCustom/fontcustom/pull/191))
* Add multiple classes to config file ([#174](https://github.com/FontCustom/fontcustom/issues/174))
* Don't strip "%" symbol (and other potentially valid characters) from CSS selector ([#173](https://github.com/FontCustom/fontcustom/issues/173))
* Fix bug where custom template path appears in output filenames ([#198](https://github.com/FontCustom/fontcustom/pull/198), [#172](https://github.com/FontCustom/fontcustom/issues/172))
* SCSS content variables like Font Awesome ([#151](https://github.com/FontCustom/fontcustom/issues/151))
* Running compile on a folder containing directories shouldn't throw an error

## 1.3.3 (2/20/2014)

* Removes ttfautohint ([#160c](https://github.com/FontCustom/fontcustom/pull/160#issuecomment-34593191))
* Fixes rails-scss template helper ([#185](https://github.com/FontCustom/fontcustom/issues/185))
* Adds `text-rendering: optimizeLegibility` ([#181](https://github.com/FontCustom/fontcustom/pull/181))

## 1.3.2 (1/31/2014)

* Fixes `preprocessor_path` for Rails asset pipeline / Sprockets ([#162](https://github.com/FontCustom/fontcustom/pull/162), [#167](https://github.com/FontCustom/fontcustom/pull/167))
* Fixes bug where `preprocessor_path` was ignored by the scss template ([#171](https://github.com/FontCustom/fontcustom/issues/171))
* Fixes bug where relative output paths containing ".." would fail to compile

## 1.3.1 (12/28/2013)

* Fixes syntax error in generate.py that affects Python 2.6

## 1.3.0 (12/24/2013)

**If upgrading from 1.2.0, delete your old `.fontcustom-manifest.json` and output directories first.**

The big news: fixed glyph code points. Automatically assigned for now, but changing them by hand is just a matter of modifying the generated `.fontcustom-manifest.json`. A few breaking changes (`css_prefix`, custom template syntax, possibly others).

* Adds fixed glyph code points ([#56](https://github.com/FontCustom/fontcustom/issues/56))
* Drops bootstrap templates (maintenance overhead, unsure if anyone was using them)
* Stores relative paths for collaborative editing ([#149](https://github.com/FontCustom/fontcustom/pull/149))
* Changes `css_prefix` to `css_selector` to allow greater flexibility ([#126](https://github.com/FontCustom/fontcustom/pull/126))
* Skips compilation if inputs have not changed (and `force` option to bypass checks)
* Adds CSS template helpers for convenience and DRYness
* Improves rendering on Chrome Windows ([#143](https://github.com/FontCustom/fontcustom/pull/143))
* Improves Windows hinting ([#160](https://github.com/FontCustom/fontcustom/pull/160))
* Fixes Python 2.6 optsparse syntax ([#159](https://github.com/FontCustom/fontcustom/issues/159))
* Fixes bug where changes in custom templates were not detected by `watch`
* Improves error and debuggging messages

## 1.2.0 (11/2/2013)

* Preparation for fixed glyph code points.
  * Tweaks command line options (more semantic aliases)
  * Renames :data_cache to :manifest
* Sets the stage for a more streamlined, predictable workflow
  * Drops EPS support (was buggy and unused)
  * Turns glyph width adjustment into an option (off by default) ([#137](https://github.com/FontCustom/fontcustom/pull/137))
* Relaxes all dependency version requirements ([#127](https://github.com/FontCustom/fontcustom/issues/127))

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
