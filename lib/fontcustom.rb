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
    :output => "./FONT_NAME",
    :config => "./fontcustom.yml -or- ./config/fontcustom.yml",
    :templates => "css preview"
  }

  DEFAULT_OPTIONS = {
    :input => nil,
    :output => nil,
    :config => nil,
    :templates => %w|css preview|,
    :font_name => "fontcustom",
    :font_design_size => 16,
    :font_em => 512,
    :font_ascent => 448,
    :font_descent => 64,
    :css_selector => ".icon-{{glyph}}",
    :preprocessor_path => nil,
    :autowidth => false,
    :no_hash => false,
    :debug => false,
    :force => false,
    :quiet => false,
    :single_quotes => false,
    :css3 => false
  }
end
