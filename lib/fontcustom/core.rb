require 'fontcustom/thor_extension'
require 'fontcustom/font_generator'
require 'fontcustom/stylesheet_generator'
require 'fontcustom/watcher'

module Fontcustom
  # Both .compile and .watch take the following arguments:
  #
  # @param [String] the input dir
  # @param [String] the output dir (optional, defaults to fontcustom/ adjacent to the input dir)
  class Core
    def self.compile(*args)
      config = args.last.is_a?(::Hash) ? args.pop : {}

      # Thor::Group returns an array of each task's return value
      # We want the last one: a hash of the generated font's data
      font = Fontcustom::FontGenerator.start(args, config).last
      Fontcustom::StylesheetGenerator.start([font], config)
    end

    def self.watch(*args)
      Fontcustom::Watcher.watch(*args)
    end

    def self.stop
      Fontcustom::Watcher.stop
    end
  end
end
