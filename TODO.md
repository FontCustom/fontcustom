## TODO

### FC::Gen::Manifest

should read manifest
should create manifest if it doesn't exist
should overwrite manifest with any changed options
should export representation of itself

### FC::Gen::Font

should read manifest
should create glyph code points if they don't exist
should add code points for any new glyphs
should populate manifest with glyphs
should garbage collect old fonts
should call fontforge
should announce new fonts after generation completes

### generate.py

should read manifest
should generate fonts
should populate manifest with fonts

### FC::Gen::Template

should read manifest
should garbage collect old templates
should generate templates
should populate manifest with templates

---

### Must Have

* Options should load previous options from manifest
* Integration tests (aruba?)

### Nice to Have

* more robust fontforge check than `which`
* rename Options to OptionsParser
* shorten options (e.g. :project_root => :root)
* remove redundant requires
