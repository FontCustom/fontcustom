require "yaml"
require "thor/group"
require "thor/actions"

module Fontcustom
  module Generator
    class Font < Thor::Group
      include Thor::Actions

      # Instead of passing each option individually as a Thor option,
      # we're passing the entire option hash as an argument. This is
      # way DRYier, easier to maintain.
      argument :opts 

      def check_input
        if ! File.directory? opts[:input]
          raise Fontcustom::Error, "#{opts[:input]} doesn't exist or isn't a directory."
        elsif Dir[File.join(opts[:input], "*.{svg,eps}")].empty?
          raise Fontcustom::Error, "#{opts[:input]} doesn't contain any vectors (*.svg or *.eps files)."
        end
      end

      def check_output
        if File.exists? File.join(opts[:output], ".fontcustom-data")
          # Skip ahead, everything is in order
        elsif File.exists?(opts[:output]) && ! File.directory?(opts[:output])
          raise Fontcustom::Error, "#{opts[:output]} already exists but isn't a directory."
        else
          # creates opts[:output] as well
          add_file File.join(opts[:output], ".fontcustom-data") 
        end
      end

      def get_data
        data = File.join(opts[:output], ".fontcustom-data")
        data = YAML.load(File.open(data)) if File.exists? data
        @data = data.is_a?(Hash) ? data : {}
      end

      def reset_output
        return unless @data[:files]
        begin
          deleted = []
          @data[:files].each do |file| 
            remove_file(file)
            deleted << file
          end
        ensure
          @data[:files] = @data[:files] - deleted
          yaml = @data.to_yaml.sub("---\n", "")
          file = File.join(opts[:output], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, yaml
        end
      end

    end
  end
end
