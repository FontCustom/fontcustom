## TODO

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

### Nice to Have

* more robust fontforge check than `which`
* rename Options to OptionsParser
* shorten options (e.g. :project_root => :root)
* remove redundant requires
