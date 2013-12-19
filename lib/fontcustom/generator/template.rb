require "json"
require "pathname"

module Fontcustom
  module Generator
    class Template
      include Utility

      attr_reader :manifest, :options

      def initialize(manifest)
        @manifest = Fontcustom::Manifest.new manifest
        @options = @manifest.get :options
      end

      def generate
        if ! @manifest.get(:fonts).empty?
          delete_old_templates
          set_relative_paths
          create_files
        else
          raise Fontcustom::Error, "No generated fonts were detected - aborting template generation."
        end
      end

      private

      def delete_old_templates
        @manifest.delete :templates
      end

      def set_relative_paths
        fonts = @manifest.get :fonts
        name = File.basename fonts.first, File.extname(fonts.first)
        fonts_path = Pathname.new @options[:output][:fonts]
        css_path = Pathname.new @options[:output][:css]
        preview_path = Pathname.new @options[:output][:preview]
        @font_path = File.join fonts_path.relative_path_from(css_path).to_s, name
        @font_path_alt = @options[:preprocessor_path].nil? ? @font_path : File.join(@options[:preprocessor_path], name)
        @font_path_preview = File.join fonts_path.relative_path_from(preview_path).to_s, name
      end

      def create_files
        @glyphs = @manifest.get :glyphs
        existing = @manifest.get :templates
        created = []
        begin
          @options[:templates].each do |source|
            begin
              target = template_target source
              template source, target, :verbose => false, :force => true
            rescue => e
              raise Fontcustom::Error, "Could not generate template `#{source}`:#{line_break + e.message}" 
            end
            created << target
          end
        ensure
          say_changed :create, created
          @manifest.set :templates, (existing + created).uniq
        end
      end

      def template_target(source)
        packaged = %w|fontcustom.css _fontcustom.scss _fontcustom-rails.scss fontcustom-preview.html|
        css_exts = %w|.css .scss .sass .less .stylus|
        name = File.basename source
        ext = File.extname source
        target = name.dup

        if packaged.include?(name) && @options[:font_name] != DEFAULT_OPTIONS[:font_name]
          target.sub! DEFAULT_OPTIONS[:font_name], @options[:font_name]
        end

        if @options[:output].keys.include? name.to_sym
          File.join @options[:output][name.to_sym], target
        elsif css_exts.include? ext
          File.join @options[:output][:css], target
        elsif name == "fontcustom-preview.html"
          File.join @options[:output][:preview], target
        else
          File.join @options[:output][:fonts], target
        end
      end

      #
      # Template Helpers
      #

      def font_name
        @options[:font_name]
      end

      def font_face(style = :normal)
        case style
        when :rails
          url = "font-url"
          path = @font_path_alt
        when :preview
          url = "url"
          path = @font_path_preview
        else
          url = "url"
          path = @font_path
        end
%Q|@font-face {
  font-family: "#{font_name}";
  src: #{url}("#{path}.eot");
  src: #{url}("#{path}.eot?#iefix") format("embedded-opentype"),
       #{url}("#{path}.woff") format("woff"),
       #{url}("#{path}.ttf") format("truetype"),
       #{url}("#{path}.svg##{font_name}") format("svg");
  font-weight: normal;
  font-style: normal;
}|
      end

      def glyph_selectors
        output = @glyphs.map do |name, value|
          @options[:css_selector].sub("{{glyph}}", name.to_s) + ":before"
        end
        output.join ",\n"
      end

      def glyphs
        output = @glyphs.map do |name, value|
          %Q|#{@options[:css_selector].sub('{{glyph}}', name.to_s)}:before { content: "\\#{value[:codepoint].to_s(16)}"; }|
        end
        output.join "\n"
      end
    end
  end
end
