require "json"
require "pathname"

module Fontcustom
  module Generator
    class Template
      include Utility

      def initialize(manifest)
        @manifest = get_manifest(manifest)
        @options = @manifest[:options]
        enable_thor_ations
      end

      def generate
      end

      # Required for Thor::Actions#template
      def self.source_root
        File.join Fontcustom.gem_lib, "templates"
      end

      private

      def make_relative_paths
        name = File.basename @data[:fonts].first, File.extname(@data[:fonts].first)
        fonts = Pathname.new opts.output[:fonts]
        css = Pathname.new opts.output[:css]
        preview = Pathname.new opts.output[:preview]
        @font_path = File.join fonts.relative_path_from(css).to_s, name
        @font_path_alt = opts.preprocessor_path.nil? ? @font_path : File.join(opts.preprocessor_path, name)
        @font_path_preview = File.join fonts.relative_path_from(preview).to_s, name
      end

      def create_files
        @glyphs = @data[:glyphs]
        @glyphcodes = @data[:glyphcodes]
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

            target = if opts.output.keys.include? name.to_sym
              File.join opts.output[name.to_sym], target
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
          overwrite_file opts.manifest, json
        end
      end
    end
  end
end
