require 'thor'
require 'fontcustom'

module Fontcustom
  class CLI < Thor
    desc 'compile INPUT_DIR [OUTPUT_DIR]', 'Generates icon webfonts and a corresponding CSS file from a collection of vector images.'
    #method_options :alias => 'c'
    def compile(input, output)
      names = Fontcustom::FontGenerator.start(input, output)
      Fontcustom::StylesheetGenerator.start(names, output)
    end
  end
end
