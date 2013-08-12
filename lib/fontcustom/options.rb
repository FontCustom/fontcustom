require "thor/core_ext/hash_with_indifferent_access"

module Fontcustom
  # :output and :config are build from arguments
  DEFAULT_OPTIONS = Thor::CoreExt::HashWithIndifferentAccess.new({
    :project_root => Dir.pwd,
    :input => "",
    :templates => %w|css preview|,
    :font_name => "fontcustom",
    :file_hash => true,
    :css_prefix => "icon-",
    :preprocessor_font_path => "",
    :debug => false,
    :verbose => true
  })

  DATA_MODEL = Thor::CoreExt::HashWithIndifferentAccess.new({
    :fonts => [],
    :templates => [],
    :glyphs => [],
    :paths => {
      :css_to_fonts => "",
      :preprocessor_to_fonts => "",
      :preview_to_css => ""
    }
  })
end
