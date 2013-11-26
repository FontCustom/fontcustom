## TODO

### 1.3.0

* tests, error messages, and docs for generate.py / SVG bugs
* tests, error messages, and docs for template generator

* store relative paths in manifest (rebuild in generator/util)
* Ensure :css_selector is `.strip`ed and has "{{glyph}}" in it
* Detect old manifest / show error message
* In template/fontcustom.yml, clarify that input/output can be hashes

* Add more travis CLI rubies / thor versions?
* documentation for template helpers
* redirect fontcustom.com to github repo (use wiki for documentation)

### Low Priority

* conserve code points: http://stackoverflow.com/questions/8794430/ruby-finding-lowest-free-id-in-an-id-array
* more flexible input/ouput hashes (regex or file extensions)
* sass template with variables
* less template with variables
* more robust fontforge check than `which`
* remove redundant requires
* rename options for succintness (e.g. :project_root => :root)
* trim options specs down
