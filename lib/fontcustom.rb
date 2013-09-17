require "fontcustom/version"
require "fontcustom/error"
require "fontcustom/util"
require "fontcustom/options"
require "fontcustom/generator/font"
require "fontcustom/generator/template"

module Fontcustom
  ##
  # Clean Ruby API to workaround Thor
  def compile(options)
    opts = Options.new options
    Generator::Font.start [opts]
    Generator::Template.start [opts]
  rescue Fontcustom::Error => e
    opts.say_message :error, e.message, :red
  end

  def gem_lib
    File.expand_path(File.join(File.dirname(__FILE__), "fontcustom"))
  end

  module_function :compile, :gem_lib

  ##
  # These are used in Thor CLI but overridden when the Options class is built
  EXAMPLE_OPTIONS = {
    :project_root => "`pwd`",
    :output => "PROJECT_ROOT/FONT_NAME"
  }

  DEFAULT_OPTIONS = {
    :project_root => Dir.pwd,
    :input => nil,
    :output => nil,
    :config => nil,
    :data_cache => nil,
    :templates => %w|css preview|,
    :font_name => "fontcustom",
    :file_hash => true,
    :css_prefix => "icon-",
    :preprocessor_path => "",
    :debug => false,
    :verbose => true
  }

  DATA_MODEL = {
    :fonts => [],
    :templates => [],
    :glyphs => [],
    :paths => {
      :css_to_fonts => "",
      :preprocessor_to_fonts => ""
    }
  }
end
