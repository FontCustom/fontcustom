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

  module_function :compile
end
