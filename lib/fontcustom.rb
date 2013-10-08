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
    :output => "PROJECT_ROOT/FONT_NAME",
    :config => "PROJECT_ROOT/fontcustom.yml OR PROJECT_ROOT/config/fontcustom.yml",
    :templates => "css preview",
    :data_cache => "CONFIG_DIR/.fontcustom-data OR at PROJECT_ROOT/.fontcustom-data"
  }

  DEFAULT_OPTIONS = {
    :project_root => Dir.pwd,
    :input => nil,
    :output => nil,
    :config => nil,
    :templates => %w|css preview|,
    :font_name => "fontcustom",
    :css_prefix => "icon-",
    :css_postfix => "",
    :data_cache => nil,
    :preprocessor_path => nil,
    :no_hash => false,
    :debug => false,
    :quiet => false
  }

  DATA_MODEL = {
    :fonts => [],
    :templates => [],
    :glyphs => []
  }
end
