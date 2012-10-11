require 'fontcustom/font_generator'
require 'fontcustom/stylesheet_generator'
require 'fontcustom/watcher'

module Fontcustom
  class Core
    def self.compile(input, *args)
      font_options = {
        :input => input,
        :output => File.join(File.dirname(input), 'fontcustom'),
        :verbose => true
      }

      if args.last.is_a?(::Hash) && args.last.instance_of?(::Hash)
        font_options.merge!(args.pop)
      end

      # Thor::Group returns an array of each task's return value
      # We want the last one: a hash of the generated font's data
      font = Fontcustom::FontGenerator.start([font_options]).last

      stylesheet_options = {
        :icons => font['files'],
        :font => File.basename(font['font']),
        :output => font_options[:output],
        :verbose => font_options[:verbose]
      }
      Fontcustom::StylesheetGenerator.start([stylesheet_options])
    end
  end
end
