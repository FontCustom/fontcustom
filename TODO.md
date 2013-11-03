## TODO

```
Manifest
  options:
    (all options)
  glyphs:
    {:name => codepoint}
  fonts:
  templates:
  checksum:
    current:
    previous:
```

### FC::Base

should pass CLI options to FC::Options
should init a FC::Gen::Manifest with options
should set checksum[:current] to md5 hash of vectors, templates, and options
when checksum[:current] != checksum[:previous]
  should init a FC::Gen::Font with manifest_path
  should init a FC::Gen::Template with manifest_path
  should set checksum[:previous] to checksum[:current]
when checksum[:current] == checksum[:previous]
  should show "no change" message

### FC::Options

should parse CLI options

### FC::Gen::Manifest

should read manifest
should create manifest if it doesn't exist
should overwrite manifest with any changed options

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

### FC::Util

should read from manifest
should save to manifest
should garbage collect a list of files
should update manifest while garbage collecting
