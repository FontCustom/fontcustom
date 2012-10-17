require 'fontcustom/version'
require 'fontcustom/generator'
require 'fontcustom/watcher'

module Fontcustom
  # Both .compile and .watch take the following arguments:
  #
  # @param [String] the input dir
  # @param [String] the output dir (optional, defaults to fontcustom/ adjacent to the input dir)
  # @param [Hash] options for Thor (not working)
  def compile(*args)
    config = args.last.is_a?(::Hash) ? args.pop : {}
    Fontcustom::Generator.start(args, config)
  end

  def watch(*args)
    Fontcustom::Watcher.watch(*args)
  end

  def stop
    Fontcustom::Watcher.stop
  end

  module_function :compile, :watch, :stop
end
