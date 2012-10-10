require 'fontcustom/version'
require 'fontcustom/font_generator'
require 'fontcustom/stylesheet_generator'

module Fontcustom
  def compile(input_dir, output_dir = File.join(File.dirname(input_dir), 'fontcustom'))
    font = Fontcustom::FontGenerator.start([input_dir, output_dir])
    font = font.last
    Fontcustom::StylesheetGenerator.start([font['files'], font['font'], output_dir])
  end
  module_function :compile
end
