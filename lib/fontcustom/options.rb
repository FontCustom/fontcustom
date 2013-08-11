require "thor/core_ext/hash_with_indifferent_access"

module Fontcustom
  # :output and :config are build from arguments
  DEFAULT_OPTIONS = Thor::CoreExt::HashWithIndifferentAccess.new({
    :project_root => Dir.pwd,
    :input => "",
    :templates => %w|css preview|,
    :font_name => "Font Custom",
    :file_hash => true,
    :css_prefix => "icon-",
    :font_face_path => false,
    :debug => false,
    :verbose => true
  })

  DATA_MODEL = Thor::CoreExt::HashWithIndifferentAccess.new({
    :fonts => [],
    :fonts_previous => [],
    :templates => [],
    :file_name => "",
    :glyphs => []
  })
end
