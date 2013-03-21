require "yaml"
require "thor"
require "thor/actions"

class Fontcustom
  class Util < Thor
    include Thor::Actions
    
    no_tasks do 
      def root
        File.expand_path(File.join(File.dirname(__FILE__)))
      end

      def template(name)
        File.join root, "templates", name
      end

      def verify_all(options)
        verify_fontforge(`which fontforge`)
        verify_input_dir(options.input_dir)
        verify_output_dir(options.output_dir)
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

      def verify_output_dir(output)
        if File.directory? output
          reset_output output
        elsif File.exists? output
          raise Thor::Error, "#{output} already exists but isn't a directory."
        else
          empty_directory output
        end
      end

      def reset_output(output)
        data_file = File.join(output, ".fontcustom-data")
        if File.exists? data_file
          paths = YAML.load_file data_file
          unless paths.empty?
            paths.each { |file| remove_file File.join(output, file) }
            clear_file data_file
          end
        else
          add_file data_file
        end
      end

      def clear_file(file)
        File.open(file, "w") {}
      end
    end
  end
end
