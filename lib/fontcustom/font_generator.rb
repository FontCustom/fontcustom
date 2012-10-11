require 'json'
require 'thor/group'

module Fontcustom
  class FontGenerator < Thor::Group
    include Thor::Actions

    desc 'Generates webfonts from given directory of vectors.'

    argument :input, :type => :string
    argument :output, :type => :string, :optional => true

    def self.source_root
      File.dirname(__FILE__)
    end

    def verify_input_dir
      if ! File.directory?(input)
        raise ArgumentError, "#{input} doesn't exist or isn't a directory."
      end
    end

    def create_output_dir
      @output = output.nil? ? File.join(File.dirname(input), 'fontcustom') : output
      empty_directory(@output)
    end

    def generate
      gem_file_path = File.expand_path(File.join(File.dirname(__FILE__)))
      @font = %x| fontforge -script #{gem_file_path}/scripts/generate.py #{input} #{@output} 2>&1 /dev/null |
      @font = JSON.parse(@font.split("\n").last)
    end

    def show_paths
      path = @font['file']
      ['woff','otf','ttf','eot'].each do |type|
        say_status(:create, path + '.' + type)
      end
    end

    ##
    # Thor::Group returns an array of each method's return value
    # Access this with: catpured_output.last
    def return_info
      @font['file'] = File.basename(@font['file'])
      @font.merge!(:output => @output)
    end
  end
end
