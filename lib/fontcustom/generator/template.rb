require "json"
require "pathname"
require "thor"
require "thor/group"
require "thor/actions"

module Fontcustom
  module Generator
    class Template < Thor::Group
      include Util
      include Thor::Actions

      # Instead of passing each option individually we're passing the entire options hash as an argument.
      # This is DRYier, easier to maintain.
      argument :opts

      # Required for Thor::Actions#template
      def self.source_root
        File.join Fontcustom.gem_lib, "templates"
      end

      def get_data
        if File.exists? opts.data_cache
          @data = JSON.parse(File.read(opts.data_cache), :symbolize_names => true)
        else
          raise Fontcustom::Error, "#{relative_to_root(opts.data_cache)} is required to generate templates, but I couldn't find it."
        end
      rescue JSON::ParserError
        # Catches both empty and and malformed files
        raise Fontcustom::Error, "#{relative_to_root(opts.data_cache)} is empty or corrupted. Try deleting the file and running Fontcustom::Generator::Font again to regenerate the data file. Old generated files may need to be deleted manually."
      end

      def reset_output
        return if @data[:templates].empty?
        begin
          deleted = []
          @data[:templates].each do |file|
            remove_file file, :verbose => false
            deleted << file
          end
        ensure
          @data[:templates] = @data[:templates] - deleted
          json = JSON.pretty_generate @data
          overwrite_file opts.data_cache, json
          say_changed :removed, deleted
        end
      end

      def make_relative_paths
        name = File.basename @data[:fonts].first, File.extname(@data[:fonts].first)
        fonts = Pathname.new opts.output[:fonts]
        css = Pathname.new opts.output[:css]
        preview = Pathname.new opts.output[:preview]
        @data[:paths][:css_to_fonts] = File.join fonts.relative_path_from(css).to_s, name
        @data[:paths][:preprocessor_to_fonts] = if opts.preprocessor_path != ""
          File.join opts.preprocessor_path, name
        else
          @data[:paths][:css_to_fonts]
        end
      end

      def generate
        @opts = opts # make available to templates
        begin
          created = []
          opts.templates.each do |source|
            name = File.basename source
            ext = File.extname source
            target = if opts.output.keys.include? name
                       File.join opts.output[name], name
                     elsif %w|.css .scss .sass .less .stylus|.include? ext
                       File.join opts.output[:css], name
                     elsif name == "fontcustom-preview.html" || name == "fontcustom-preview.css"
                       File.join opts.output[:preview], name
                     else
                       File.join opts.output[:fonts], name
                     end

            template source, target, :verbose => false
            created << target
          end
        ensure
          @data[:templates] = (@data[:templates] + created).uniq
          json = JSON.pretty_generate @data
          overwrite_file opts.data_cache, json
        end
      end
    end
  end
end
