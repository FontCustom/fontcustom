require "yaml"
require "thor"
require "thor/group"
require "thor/actions"

module Fontcustom
  module Generator
    class Template < Thor::Group
      include Thor::Actions
      
      # Instead of passing each option individually we're passing the entire options hash as an argument. 
      # This is DRYier, easier to maintain.
      argument :opts 

      # Required for Thor::Actions#template
      def self.source_root
        File.join Fontcustom::Util.gem_lib_path, "templates"
      end

      def get_data
        data = File.join(opts[:output], ".fontcustom-data")
        if File.exists? data
          @data = YAML.load(File.open(data))
        else
          raise Fontcustom::Error, "We couldn't find a .fontcustom-data file in #{opts[:output]}. Try again?"
        end
      end

      def check_templates
        if opts[:templates].empty?
          raise Fontcustom::Error, "No templates were specified. Check your options and try again."
        end
      end

      def reset_output
        return if @data[:templates].empty?
        begin
          deleted = []
          @data[:templates].each do |file| 
            remove_file File.join(opts[:output], file), :verbose => opts[:verbose]
            deleted << file
          end
        ensure
          @data[:templates] = @data[:templates] - deleted
          yaml = @data.to_yaml.sub("---\n", "")
          file = File.join(opts[:output], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, yaml, :verbose => false # clear data file silently
        end
      end

      def generate
        begin 
          created = []
          opts[:templates].each do |source|
            name = File.basename source
            destination = File.join opts[:output], name
            template source, destination, :verbose => opts[:verbose]
            created << name
          end
        ensure
          @data[:templates] = (@data[:templates] + created).uniq # TODO better way of cleaning up templates
          yaml = @data.to_yaml.sub("---\n", "")
          file = File.join(opts[:output], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, yaml, :verbose => opts[:verbose]
        end
      end
    end
  end
end
