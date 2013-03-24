require 'fontcustom/version'
require 'fontcustom/util'

class Fontcustom
  # NOTE
  # Thor::Actions are finicky when mixed in a module or as class methods
  # Including here until I come up with a better work-around.
  UTIL = Fontcustom::Util.new

  def self.method_missing(name, *args, &block)
    if UTIL.methods.include? name
      UTIL.send name, *args, &block
    else
      super
    end
  end

  def self.respond_to?(name)
    if UTIL.methods.include? name
      true
    else
      false
    end
  end

  module Generator
  end
end

require 'fontcustom/options'
require 'fontcustom/generator/font'
require 'fontcustom/generator/template'
