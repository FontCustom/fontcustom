require 'fontcustom/version'
require 'fontcustom/util'
require 'fontcustom/font_generator'
require 'fontcustom/stylesheet_generator'

module Fontcustom
  def compile(input, *args)
    font_options = {
      :input => input,
      :output => File.join(File.dirname(input), 'fontcustom'),
      :verbose => true
    }.merge!(args.extract_options!)

    # Thor::Group returns an array of each task's return value
    # We want the last one: a hash of the generated font's data
    font = Fontcustom::FontGenerator.start([font_options]).last

    stylesheet_options = {
      :icons => font['files'],
      :font => font['font'],
      :output => font_options[:output],
      :verbose => font_options[:verbose]
    }
    Fontcustom::StylesheetGenerator.start([stylesheet_options])
  end
  module_function :compile
end
