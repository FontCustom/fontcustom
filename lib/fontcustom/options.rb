module Fontcustom
  DEFAULT_OPTIONS = {
    :input => Dir.pwd,
    :output => false, # used to assign default, if necessary 
    :config => false,
    :templates => %w|css preview|, 
    :font_name => "fontcustom",
    :file_hash => true,
    :css_prefix => "icon-",
    :font_face_path => false,
    :debug => false,
    :verbose => true
  }

  DATA_MODEL = {
    :fonts => [],
    :templates => [],
    :file_name => "",
    :glyphs => []
  }
end
