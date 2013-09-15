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
          raise Fontcustom::Error, "`#{relative_to_root(opts.data_cache)}` is missing. This file is required to generate templates."
        end
      rescue JSON::ParserError
        raise Fontcustom::Error, "`#{relative_to_root(opts.data_cache)}` is empty or corrupted. Delete it to start from scratch. Note: Any previously generated files will need to be deleted manually."
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
          say_changed :delete, deleted
        end
      end

      def make_relative_paths
        name = File.basename @data[:fonts].first, File.extname(@data[:fonts].first)
        fonts = Pathname.new opts.output[:fonts]
        css = Pathname.new opts.output[:css]
        preview = Pathname.new opts.output[:preview]
        @data[:paths][:css_to_fonts] = File.join fonts.relative_path_from(css).to_s, name
        @data[:paths][:preview_to_fonts] = File.join fonts.relative_path_from(preview).to_s, name
        @data[:paths][:preprocessor_to_fonts] = if opts.preprocessor_path != ""
          File.join opts.preprocessor_path, name
        else
          @data[:paths][:css_to_fonts]
        end
      end

      def generate
        @glyphs = @data[:glyphs]
        @font_path = @data[:paths][:css_to_fonts]
        @font_path_pre = @data[:paths][:preprocessor_to_fonts]
        created = []
        packaged = %w|fontcustom-bootstrap-ie7.css fontcustom.css _fontcustom-bootstrap-ie7.scss _fontcustom-rails.scss 
                   fontcustom-bootstrap.css fontcustom-preview.html _fontcustom-bootstrap.scss _fontcustom.scss|
        css_exts = %w|.css .scss .sass .less .stylus|
        begin
          opts.templates.each do |source|
            name = File.basename source
            ext = File.extname source
            target = name.dup

            if packaged.include?(name) && opts.font_name != DEFAULT_OPTIONS[:font_name]
              target.sub! DEFAULT_OPTIONS[:font_name], opts.font_name
            end

            target = if opts.output.keys.include? name
              File.join opts.output[name], target
            elsif css_exts.include? ext
              File.join opts.output[:css], target
            elsif name == "fontcustom-preview.html"
              File.join opts.output[:preview], target
            else
              File.join opts.output[:fonts], target
            end

            template source, target, :verbose => false
            created << target
          end
        ensure
          say_changed :create, created
          @data[:templates] = (@data[:templates] + created).uniq
          json = JSON.pretty_generate @data
          overwrite_file opts.data_cache, json
        end
      end
    end
  end
end
