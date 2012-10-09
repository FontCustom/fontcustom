require 'json'
require 'thor/group'

module Fontcustom
  class FontGenerator < Thor::Group
    include Thor::Actions

    desc 'Generates webfonts from given directory of vectors.'

    argument :input_dir, :type => :string
    argument :output_dir, :type => :string

    def self.source_root
      File.dirname(__FILE__)
    end

    def verify_and_create_directories
      if ! File.directory?(input_dir)
        raise "#{input_dir} doesn't exist or isn't a directory."
      end

      empty_directory output_dir
    end

    def generate
      gem_file_path = File.expand_path(File.join(File.dirname(__FILE__)))
      @output = %x| fontforge -script #{gem_file_path}/scripts/generate.py #{input_dir} #{output_dir} 2>&1 /dev/null |
    end

    def return_icon_names
      @output = JSON.parse(@output.split("\n").last)
      @output['files']
    end
  end
end
