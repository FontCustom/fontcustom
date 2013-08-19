require "fontcustom/version"
require "fontcustom/error"
require "fontcustom/options"
require "fontcustom/util"
require "fontcustom/generator/font"
require "fontcustom/generator/template"
require "thor/core_ext/hash_with_indifferent_access"

module Fontcustom
  ##
  # Clean Ruby API to workaround Thor
  def compile(options)
    opts = Fontcustom::Options.collect_options options
    Fontcustom::Generator::Font.start [opts]
    Fontcustom::Generator::Template.start [opts]
  rescue Fontcustom::Error => e
    puts "ERROR: #{e.message}"
  end

  def gem_lib
    File.expand_path(File.join(File.dirname(__FILE__), "fontcustom"))
  end

  module_function :compile, :gem_lib

  ##
  # Temporary holding spot for these constants
  # :output, :config, and :data are build from arguments
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
