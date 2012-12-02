require 'fontcustom/version'
require 'fontcustom/generator'
require 'fontcustom/watcher'

module Fontcustom
  # Usage:
  # Fontcustom.compile 'path/to/vectors', '-o', 'path/to/output'
  def compile(*args)
    Fontcustom::Generator.start(args) # as array
  end

  def watch(*args)
    Fontcustom::Watcher.watch(*args)
  end

  def stop
    Fontcustom::Watcher.stop
  end

  module_function :compile, :watch, :stop
end
