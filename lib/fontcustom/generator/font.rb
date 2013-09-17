require "json"
require "open3"
require "thor"
require "thor/group"
require "thor/actions"

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
            @data = data.is_a?(Hash) ? symbolize_hash(data) : Fontcustom::DATA_MODEL.dup
          rescue
            raise Fontcustom::Error, "Couldn't parse `#{relative_to_root(opts.data_cache)}`. Delete it to start from scratch. Any previously generated files will need to be deleted manually."
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
        cmd = "fontforge -script #{Fontcustom.gem_lib}/scripts/generate.py #{opts.input[:vectors]} #{opts.output[:fonts] + name + hash}"

        output, err, status = execute_and_clean(cmd)
        @json = output.delete_at(0)

        say_status :debug, "#{err}\n#{' ' * 14}#{output}", :red if opts.debug
        raise Fontcustom::Error, "`fontforge` compilation failed. Try again with --debug for more details." unless status.success?
      end

      def collect_data
        json = JSON.parse(@json, :symbolize_names => true)
        @data.merge! json
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

      private

      def execute_and_clean cmd
        stdout, stderr, status = Open3::capture3(cmd)
        stdout = stdout.split("\n")
        stdout = stdout[1..-1] if stdout[0] == "CreateAllPyModules()"
        [stdout, stderr, status]
      end
    end
  end
end
