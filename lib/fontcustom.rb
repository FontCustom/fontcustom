require "fontcustom/version"
require "fontcustom/error"
require "fontcustom/utility"
require "fontcustom/base"
require "fontcustom/manifest"
require "fontcustom/options"
require "fontcustom/generator/font"
require "fontcustom/generator/template"

module Fontcustom
  def gem_lib
    File.expand_path(File.join(File.dirname(__FILE__), "fontcustom"))
  end
  module_function :gem_lib

  ##
  # Hack to get Thor to show more helpful defaults in `fontcustom help`. These
  # are overwritten in Fontcustom::Options.
  EXAMPLE_OPTIONS = {
    :project_root => "`pwd`",
    :output => "PROJECT_ROOT/FONT_NAME",
    :config => "PROJECT_ROOT/fontcustom.yml -or- PROJECT_ROOT/config/fontcustom.yml",
    :templates => "css preview",
    :manifest => "CONFIG_DIR/.fontcustom-manifest.json -or- PROJECT_ROOT/.fontcustom-manifest.json"
  }

  DEFAULT_OPTIONS = {
    :project_root => nil,
    :input => nil,
    :output => nil,
    :config => nil,
    :templates => %w|css preview|,
    :font_name => "fontcustom",
    :css_selector => ".icon-{{glyph}}",
    :manifest => nil,
    :preprocessor_path => nil,
    :autowidth => false,
    :no_hash => false,
    :debug => false,
    :force => false,
    :quiet => false
  }
end
