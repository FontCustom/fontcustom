require "json"
require "pathname"
require "base64"

module Fontcustom
  module Generator
    class Template
      include Utility

      attr_reader :manifest

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
        fonts_path = Pathname.new(@options[:output][:fonts]).realdirpath
        css_path = Pathname.new(@options[:output][:css]).realdirpath
        preview_path = Pathname.new(@options[:output][:preview]).realdirpath
        @font_path = File.join fonts_path.relative_path_from(css_path).to_s, name
        @font_path_alt = if @options[:preprocessor_path].nil?
          @font_path
        elsif ! @options[:preprocessor_path] || @options[:preprocessor_path].empty?
          name
        else
          File.join(@options[:preprocessor_path], name)
        end
        @font_path_preview = File.join fonts_path.relative_path_from(preview_path).to_s, name
      end

      def create_files
        @glyphs = @manifest.get :glyphs
        existing = @manifest.get :templates
        created = []
        begin
          @options[:templates].each do |template_name|
            begin
              source = get_source_path(template_name)
              target = get_target_path(source)
              template source, target, :verbose => false, :force => true
            end
            created << target
          end
        ensure
          say_changed :create, created
          @manifest.set :templates, (existing + created).uniq
        end
      end

      def get_source_path(template)
        template_path = File.join Fontcustom.gem_lib, "templates"

        case template
        when "preview"
          File.join template_path, "fontcustom-preview.html"
        when "css"
          File.join template_path, "fontcustom.css"
        when "scss"
          File.join template_path, "_fontcustom.scss"
        when "scss-rails"
          File.join template_path, "_fontcustom-rails.scss"
        else
          File.join @options[:input][:templates], template
        end
      end

      def get_target_path(source)
        ext = File.extname source
        base = File.basename source
        css_exts = %w|.css .scss .sass .less .stylus|
        packaged = %w|fontcustom-preview.html fontcustom.css _fontcustom.scss _fontcustom-rails.scss|

        target = if @options[:output].keys.include? base.to_sym
          File.join @options[:output][base.to_sym], base
        elsif ext && css_exts.include?(ext)
          File.join @options[:output][:css], base
        elsif source.match(/fontcustom-preview\.html/)
          File.join @options[:output][:preview], base
        else
          File.join @options[:output][:fonts], base
        end

        if packaged.include?(base) && @options[:font_name] != DEFAULT_OPTIONS[:font_name]
          target = File.join(File.dirname(target), File.basename(target).sub(DEFAULT_OPTIONS[:font_name], @options[:font_name]))
        end

        target
      end

      #
      # Template Helpers
      #

      def font_name
        @options[:font_name]
      end

      def font_face(style = {})
        if style.is_a?(Symbol)
          if style == :preprocessor
            url = "font-url"
            path = @font_path_alt
          elsif style == :preview
            url = "url"
            path = @font_path_preview
          else
            url = "url"
            path = @font_path
          end
          say_message :warn, "`font_face(:#{style})` is deprecated. Use `font_face(url:'url', path:'path')` instead."
        else
          style = {:url => "url", :path => @font_path}.merge(style)
          url = style[:url]
          path = style[:path]
        end

        # Bulletproof @Font-Face <http://www.fontspring.com/blog/the-new-bulletproof-font-face-syntax>
        # With and without Base64
        if @options[:base64]
          string = %Q|@font-face {
  font-family: #{quote}#{font_name}#{quote};
  font-style: normal;
  font-weight: normal;
  src: #{url}(#{quote}#{path}.eot?#{quote}) format(#{quote}embedded-opentype#{quote});
}

@font-face {
  font-family: #{quote}#{font_name}#{quote};
  font-style: normal;
  font-weight: normal;
  src: url(#{quote}data:application/x-font-woff;charset=utf-8;base64,#{woff_base64}#{quote}) format(#{quote}woff#{quote}),
       #{url}(#{quote}#{path}.ttf#{quote}) format(#{quote}truetype#{quote}),
       #{url}(#{quote}#{path}.svg##{font_name}#{quote}) format(#{quote}svg#{quote});
}|
        else
        string = %Q|@font-face {
  font-family: #{quote}#{font_name}#{quote};
  font-style: normal;
  font-weight: normal;
  src: #{url}(#{quote}#{path}.eot#{quote});
  src: #{url}(#{quote}#{path}.eot?#iefix#{quote}) format(#{quote}embedded-opentype#{quote}),
       #{url}(#{quote}#{path}.woff#{quote}) format(#{quote}woff#{quote}),
       #{url}(#{quote}#{path}.ttf#{quote}) format(#{quote}truetype#{quote}),
       #{url}(#{quote}#{path}.svg##{font_name}#{quote}) format(#{quote}svg#{quote});
}|
        end

        # For Windows/Chrome <http://stackoverflow.com/a/19247378/1202445>
        string << %Q|

@media screen and (-webkit-min-device-pixel-ratio:0) {
  @font-face {
    font-family: #{quote}#{font_name}#{quote};
    src: #{url}(#{quote}#{path}.svg##{font_name}#{quote}) format(#{quote}svg#{quote});
  }
}|
        string
      end

      def woff_base64
        woff_path = File.join(@options[:output][:fonts], "#{@font_path}.woff")
        Base64.encode64(File.binread(File.join(woff_path))).gsub("\n", "")
      end

      def glyph_selectors
        output = @glyphs.map do |name, value|
          @options[:css_selector].sub("{{glyph}}", name.to_s) + before_selector
        end
        output.join ",\n"
      end

      def glyph_properties
%Q|  display: inline-block;
  font-family: #{quote}#{font_name}#{quote};
  -moz-osx-font-smoothing: grayscale;
  -webkit-font-smoothing: antialiased;
  font-smoothing: antialiased;
  font-style: normal;
  font-variant: normal;
  font-weight: normal;
  line-height: 1;
  text-decoration: inherit;
  text-rendering: optimizeLegibility;
  text-transform: none;|
      end

      def glyphs
        output = @glyphs.map do |name, value|
          %Q|#{@options[:css_selector].sub('{{glyph}}', name.to_s)}#{before_selector} { content: #{quote}\\#{value[:codepoint].to_s(16)}#{quote}; }|
        end
        output.join "\n"
      end

      def quote
        @quote ||= @options[:single_quotes] ? "'" : '"'
      end

      def before_selector
        @before_selector ||= @options[:css3] ? '::before' : ':before'
      end
    end
  end
end
