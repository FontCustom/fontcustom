require "fontcustom/version"
require "fontcustom/options"
require "fontcustom/error"
require "fontcustom/util"
require "fontcustom/actions"
require "fontcustom/generator/font"
require "fontcustom/generator/template"

module Fontcustom
  ##
  # Clean Ruby API to workaround Thor
  def compile(options)
    opts = Fontcustom::Util.collect_options options
    Fontcustom::Generator::Font.start [opts]
    Fontcustom::Generator::Template.start [opts]
  rescue Fontcustom::Error => e
    puts "ERROR: #{e.message}"
  end

  def gem_lib
    File.expand_path(File.join(File.dirname(__FILE__), "fontcustom"))
  end

  module_function :compile, :gem_lib
end
