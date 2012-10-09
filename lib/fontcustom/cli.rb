require 'thor'
require 'fontcustom'

module Fontcustom
  class CLI < Thor
    desc 'compile INPUT_DIR [OUTPUT_DIR]', 'Generates icon webfonts and a corresponding CSS file from a collection of vector images.'
    #method_options :alias => 'c'
    def compile(input, output)
      names = Fontcustom::Generators::Font.generate(input)
      Fontcustom::Generators::CSS.generate(names)
    end
  end
end
