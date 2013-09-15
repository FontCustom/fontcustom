require "json"
require "thor"
require "thor/group"
require "thor/actions"
require "thor/core_ext/hash_with_indifferent_access"

module Fontcustom
  module Generator
    class Font < Thor::Group
      include Util
      include Thor::Actions

      # Instead of passing each option individually we're passing the entire options hash as an argument.
      # This is DRYier, easier to maintain.
      argument :opts

      def prepare_output_dirs
        dirs = opts.output.values.uniq
        dirs.each do |dir|
          unless File.directory? dir
            empty_directory dir, :verbose => opts.verbose
          end
        end
      end

      def get_data
        if File.exists? opts.data_cache
          begin
            data = File.read opts.data_cache
            data = JSON.parse(data, :symbolize_names => true) unless data.empty?
            @data = data.is_a?(Hash) ? Thor::CoreExt::HashWithIndifferentAccess.new(data) : Fontcustom::DATA_MODEL.dup
          rescue JSON::ParserError
            raise Fontcustom::Error, "`#{relative_to_root(opts.data_cache)}` is empty or corrupted. Delete it to start from scratch. Note: Any previously generated files will need to be deleted manually."
          end
        else
          @data = Fontcustom::DATA_MODEL.dup
        end
      end

      def reset_output
        return if @data[:fonts].empty?
        begin
          deleted = []
          @data[:fonts].each do |file|
            remove_file file, :verbose => false
            deleted << file
          end
        ensure
          @data[:fonts] = @data[:fonts] - deleted
          json = JSON.pretty_generate @data
          overwrite_file opts.data_cache, json
          say_changed :delete, deleted
        end
      end

      def generate
        # TODO align option naming conventions with python script
        # TODO remove name arg if default is already set in python (or rm from python)
        name = opts.font_name ? " --name " + opts.font_name : ""
        hash = opts.file_hash ? "" : " --nohash"
        cmd = "fontforge -script #{Fontcustom.gem_lib}/scripts/generate.py #{opts.input[:vectors]} #{opts.output[:fonts] + name + hash} 2>&1"

        output = `#{cmd}`.split("\n")
        @json = output[3] # JSON

        # fontforge wrongly returns the following error message if only a single glyph.
        # We can strip it out and ignore it.
        if @json == "Warning: Font contained no glyphs"
          @json = output[4]
          output = output[5..-1]
        else
          @json = output[3]
          output = output[4..-1]
        end

        say_status :debug, output, :red if opts.debug

        unless $?.success?
          raise Fontcustom::Error, "`fontforge` compilation failed. Try again with --debug for more details."
        end
      end

      def collect_data
        @json = JSON.parse(@json, :symbolize_names => true)
        @data.merge! @json
        @data[:glyphs].map! { |glyph| glyph.gsub(/\W/, "-") }
        @data[:fonts].map! { |font| File.join(opts.output[:fonts], font) }
      end

      def announce_files
        say_changed :create, @data[:fonts]
      end

      def save_data
        json = JSON.pretty_generate @data
        overwrite_file opts.data_cache, json
      end
    end
  end
end
