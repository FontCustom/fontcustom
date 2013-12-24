## TODO

### 1.3.0

* redirect fontcustom.com to github repo (use wiki for documentation)

### Future

* Include fontcustom version in manifest / checksum
* Error message if using the wrong version of ruby
* Add more travis CLI rubies / thor versions?
* Detect old manifest / show error message
* Template helper that returns a hash of glyphs and pre-formatted codes
* conserve code points: http://stackoverflow.com/questions/8794430/ruby-finding-lowest-free-id-in-an-id-array
* strip /fill: rgba(...)/ from SVGs so that transparent SVGs don't fail
* more flexible input/ouput hashes (regex or file extensions)
* sass template with variables
* less template with variables
* more robust fontforge check than `which`
* remove redundant requires
