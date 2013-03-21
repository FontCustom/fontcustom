require "yaml"
require "thor" # can we just require Thor::Error?
require "thor/actions"

class Fontcustom
  class Util < Thor
    include Thor::Actions

    class << self
      def root
        File.expand_path(File.join(File.dirname(__FILE__)))
      end

      def template(name)
        File.join root, "templates", name
      end

      def verify_all
        verify_fontforge(`which fontforge`)
        verify_input_dir
        verify_dir_dir
      end

      def verify_fontforge(which) # arg to allow unit testing
        if which == ""
          raise Thor::Error, "Please install fontforge first."
        end
      end

      def verify_input_dir(input)
        if ! File.directory? input 
          raise Thor::Error, "#{input} doesn't exist or isn't a directory."
        elsif Dir[File.join(input, "*.{svg,eps}")].empty?
          raise Thor::Error, "#{input} doesn't contain any vectors (*.svg or *.eps files)."
        end
      end

      def reset_data(options)
        data_file = File.join(options.output_dir, ".fontcustom-data")
        if File.exists? data_file
          paths = YAML.load_file data_file
          unless paths[:files].empty?
            paths[:files].each { |file| remove_file File.join(options.output_dir, file) }
          end
        else
          add_file data_file
        end
      end
    end
  end
end
