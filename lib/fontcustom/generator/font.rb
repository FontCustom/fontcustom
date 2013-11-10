require "json"
require "open3"
require "thor"
require "thor/group"
require "thor/actions"

module Fontcustom
  module Generator
    class Font
      include Utility

      def initialize(manifest)
        @manifest = get_manifest(manifest)
        @options = methodize_hash @manifest[:options]
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
        return if @manifest[:fonts].empty?
        begin
          deleted = []
          @manifest[:fonts].each do |file|
            remove_file file, :verbose => false
            deleted << file
          end
        ensure
          @manifest[:fonts] = @manifest[:fonts] - deleted
          set_manifest :fonts, @manifest[:fonts]
          say_changed :delete, deleted
        end
      end

      def set_glyph_info
        codepoint = if ! @manifest[:glyphs].empty?
          @manifest[:glyphs].values.max + 1
        else
          0xf100
        end

        svgs = Dir.glob File.join(@options[:input][:vectors], "*.svg")
        svgs.map! do |name|
          name = File.basename name, ".svg"
          name.strip.gsub(/\W/, "-").downcase
        end

        # Dir.glob returns a different order depending on ruby 
        # version/platform, so we have to sort it first
        svgs.sort.each do |name|
          name = name.to_sym
          unless @manifest[:glyphs].has_key? name
            @manifest[:glyphs][name] = codepoint
            codepoint = codepoint + 1
          end
        end
        set_manifest :glyphs, @manifest[:glyphs]
      end

      def create_fonts
        #cmd = "fontforge -script #{Fontcustom.gem_lib}/scripts/generate.py #{@options[:manifest]}"
        #`#{cmd}`
        #output, err, status = execute_and_clean(cmd)
        #@json = output.delete_at(0)
        #say_status :debug, "#{err}\n#{' ' * 14}#{output}", :red if opts.debug
        #raise Fontcustom::Error, "`fontforge` compilation failed. Try again with --debug for more details." unless status.success?
      end

      def execute_and_clean(cmd)
        stdout, stderr, status = Open3::capture3(cmd)
        stdout = stdout.split("\n")
        stdout = stdout[1..-1] if stdout[0] == "CreateAllPyModules()"
        [stdout, stderr, status]
      end
    end
  end
end
