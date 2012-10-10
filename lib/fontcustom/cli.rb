require 'thor'
require 'fontcustom'

module Fontcustom
  class CLI < Thor
    desc 'compile INPUT_DIR [OUTPUT_DIR]', 'Generates icon webfonts and a corresponding CSS file from a collection of vector images.'
    def compile(input, output = nil)
      output = output.nil? ? nil : {:output => output}
      Fontcustom.compile(input, output)
    end
  end
end
