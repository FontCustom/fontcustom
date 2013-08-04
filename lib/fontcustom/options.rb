require "thor/core_ext/hash_with_indifferent_access"

module Fontcustom
  # :input, :output, and :config are build from arguments
  DEFAULT_OPTIONS = Thor::CoreExt::HashWithIndifferentAccess.new({
    :project_root => Dir.pwd,
    :templates => %w|css preview|,
    :font_name => "fontcustom",
    :file_hash => true,
    :css_prefix => "icon-",
    :font_face_path => false,
    :debug => false,
    :verbose => true
  })

  DATA_MODEL = Thor::CoreExt::HashWithIndifferentAccess.new({
    :fonts => [],
    :templates => [],
    :file_name => "",
    :glyphs => []
  })
end
