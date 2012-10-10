require 'json'
require 'thor/group'

module Fontcustom
  class FontGenerator < Thor::Group
    include Thor::Actions

    desc 'Generates webfonts from given directory of vectors.'

    argument :opts, :type => :hash

    def self.source_root
      File.dirname(__FILE__)
    end

    def verify_input_dir
      if ! File.directory?(opts[:input])
        raise ArgumentError, "#{opts[:input]} doesn't exist or isn't a directory."
      end
    end

    def create_output_dir
      empty_directory(opts[:output], :verbose => opts[:verbose])
    end

    def generate
      gem_file_path = File.expand_path(File.join(File.dirname(__FILE__)))
      @font_info = %x| fontforge -script #{gem_file_path}/scripts/generate.py #{opts[:input]} #{opts[:output]} 2>&1 /dev/null |
      @font_info = JSON.parse(@font_info.split("\n").last)
    end

    def show_paths
      return unless opts[:verbose]
      path = @font_info['font']
      ['woff','otf','ttf','eot'].each do |type|
        say_status(:create, path + '.' + type)
      end
    end

    ##
    # Thor group returns an array of each method's return value
    # Access this with: catpured_output.last
    def return_output
      @font_info
    end
  end
end
