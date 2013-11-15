require "json"
require "open3"

module Fontcustom
  module Generator
    class Font
      include Utility

      def initialize(manifest)
        @manifest = get_manifest(manifest)
        @options = @manifest[:options]
        enable_thor_actions
      end

      def generate
        create_output_dirs
        delete_old_fonts
        set_glyph_info
        create_fonts
      end

      private

      def create_output_dirs
        dirs = @options[:output].values.uniq
        dirs.each do |dir|
          unless File.directory? dir
            empty_directory dir, :verbose => ! @options[:quiet]
          end
        end
      end

      def delete_old_fonts
        delete_from_manifest(:fonts)
      end

      def set_glyph_info
        codepoint = if ! @manifest[:glyphs].empty?
          codepoints = @manifest[:glyphs].values.map { |data| data[:codepoint] }
          codepoints.max + 1
        else
          0xf100
        end

        files = Dir.glob File.join(@options[:input][:vectors], "*.svg")
        glyphs = {}
        files.each do |file|
          name = File.basename file, ".svg"
          name = name.strip.gsub(/\W/, "-").downcase
          glyphs[name.to_sym] = { :source => file }
        end

        # Dir.glob returns a different order depending on ruby
        # version/platform, so we have to sort it first
        glyphs = Hash[glyphs.sort_by { |key, val| key.to_s }]
        glyphs.each do |name, data|
          if @manifest[:glyphs].has_key? name
           data[:codepoint] = @manifest[:glyphs][name][:codepoint]
          else
            data[:codepoint] = codepoint
            codepoint = codepoint + 1
          end
        end

        @manifest[:glyphs] = glyphs
        save_manifest
      end

      def create_fonts
        cmd = "fontforge -script #{Fontcustom.gem_lib}/scripts/generate.py #{@options[:manifest]}"
        stdout, stderr, status = Open3::capture3(cmd)
        stdout = stdout.split("\n")
        stdout = stdout[1..-1] if stdout[0] == "CreateAllPyModules()"

        if status.success?
          @manifest = get_manifest
          say_changed :create, @manifest[:fonts]
        else
          debug_msg = " Try again with --debug for more details."
          if @options[:debug]
            say_message :debug, "#{stderr}\n#{' ' * 14}#{stdout}", :red
            debug_msg = ""
          end
          raise Fontcustom::Error, "`fontforge` compilation failed.#{debug_msg}"
        end
      end
    end
  end
end
