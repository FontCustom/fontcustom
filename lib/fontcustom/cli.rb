require 'thor'
require 'fontcustom'

module Fontcustom
  class CLI < Thor
    desc 'compile INPUT_DIR [OUTPUT_DIR]', 'Generates icon webfonts and a corresponding CSS file from a collection of vector images.'
    def compile(input, output = nil)
      Fontcustom.compile(input, output)
    end

    desc 'watch INPUT_DIR [OUTPUT_DIR]', 'Watches a directory of vector images for changes and regenerates icon webfonts and CSS when there are.'
    def watch(input, output = nil)
      Fontcustom.watch(input, output)
    end
  end
end
