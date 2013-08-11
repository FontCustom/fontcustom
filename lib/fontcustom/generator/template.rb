require "json"
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
        data = File.join(opts[:project_root], ".fontcustom-data")
        if File.exists? data
          @data = JSON.parse(File.read(data), :symbolize_names => true)
        else
          raise Fontcustom::Error, "There's no .fontcustom-data file in #{opts[:project_root]}. Try again?"
        end
      rescue JSON::ParserError
        # Catches both empty and and malformed files
        raise Fontcustom::Error, "The .fontcustom-data file in #{opts[:project_root]} is empty or corrupted. Try deleting the file and running Fontcustom::Generator::Font again to regenerate .fontcustom-data."
      end

      def check_templates
        if opts[:templates].empty?
          raise Fontcustom::Error, "No templates were specified. Check your options and try again?"
        end
      end

      def update_source_paths
        source_paths # assigns @source_paths
        @source_paths.unshift(opts[:input], Dir.pwd)
      end

      def reset_output
        return if @data[:templates].empty?
        begin
          deleted = []
          @data[:templates].each do |file|
            remove_file File.join(opts[:project_root], file), :verbose => opts[:verbose]
            deleted << file
          end
        ensure
          @data[:templates] = @data[:templates] - deleted
          json = JSON.pretty_generate @data
          file = File.join(opts[:project_root], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, json, :verbose => false # clear data file silently
        end
      end

      def generate
        @opts = opts # make available to templates
        begin
          created = []
          opts[:templates].each do |source|
            name = File.basename source
            ext = File.extname name
            target = if %|css scss sass less stylus|.include? ext
                       File.join opts[:output][:css], name
                     elsif name == "fontcustom-preview.html"
                       File.join opts[:output][:preview], name
                     elsif opts[:output].keys.include? name
                       File.join opts[:output][name], name
                     else
                       File.join opts[:output][:fonts], name
                     end
            template source, target, :verbose => opts[:verbose]
            created << target
          end
        ensure
          @data[:templates] = (@data[:templates] + created).uniq
          json = JSON.pretty_generate @data
          file = File.join(opts[:project_root], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, json, :verbose => opts[:verbose]
        end
      end
    end
  end
end
