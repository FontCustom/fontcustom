require "yaml"
require "thor/group"
require "thor/actions"

module Fontcustom
  module Generator
    class Template < Thor::Group
      include Thor::Actions
      
      # Instead of passing each option individually we're passing the entire option hash as an argument. 
      # This is DRYier, easier to maintain.
      argument :opts 

      def self.source_root
        File.join Fontcustom::Util.gem_lib_path, "templates"
      end

      def load_data
        data = File.join(opts[:output], ".fontcustom-data")
        if File.exists? data
          @data = YAML.load(File.open(data))
        else
          raise Fontcustom::Error, "We couldn't find a .fontcustom-data file in #{opts[:output]}. Try again?"
        end
      end

      def copy_templates
        if opts[:templates].empty?
          raise Fontcustom::Error, "No templates were specified. Check your options and try again."
        end

        begin 
          created = []
          opts[:templates].each do |source|
            name = File.basename source
            destination = File.join opts[:output], name
            template source, destination
            created << name
          end
        ensure
          @data[:files] = (@data[:files] + created).uniq # TODO better way of cleaning up templates
          yaml = @data.to_yaml.sub("---\n", "")
          file = File.join(opts[:output], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, yaml # TODO force?
        end
      end
    end
  end
end
