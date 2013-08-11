require "json"
require "thor"
require "thor/group"
require "thor/actions"
require "thor/core_ext/hash_with_indifferent_access"

module Fontcustom
  module Generator
    class Font < Thor::Group
      include Thor::Actions

      # Instead of passing each option individually we're passing the entire options hash as an argument. 
      # This is DRYier, easier to maintain.
      argument :opts 

      def prepare_output_dirs
        dirs = opts[:output].values.uniq
        dirs.each do |dir|
          unless File.directory? dir
            empty_directory dir, :verbose => opts[:verbose]
          end
        end
      end

      def get_data
        datafile = File.join opts[:project_root], ".fontcustom-data"
        if File.exists? datafile
          begin
            data = File.read datafile
            data = JSON.parse(data, :symbolize_names => true) unless data.empty?
            @data = data.is_a?(Hash) ? Thor::CoreExt::HashWithIndifferentAccess.new(data) : Fontcustom::DATA_MODEL.dup
          rescue JSON::ParserError
            raise Fontcustom::Error, "The .fontcustom-data file at #{datafile} is corrupted. Fix the JSON or delete the file to start from scratch."
          end
        else
          @data = Fontcustom::DATA_MODEL.dup
        end
      end

      def reset_output
        return if @data[:fonts_previous].empty?
        begin
          deleted = []
          @data[:fonts_previous].each do |file| 
            remove_file file, :verbose => opts[:verbose]
            deleted << file
          end
        ensure
          @data[:fonts_previous] = @data[:fonts_previous] - deleted
          json = JSON.pretty_generate @data
          file = File.join(opts[:project_root], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, json, :verbose => false # modify silently
        end
      end
      
      def generate
        # TODO align option naming conventions with python script
        # TODO remove name arg if default is already set in python (or rm from python)
        name = opts[:font_name] ? " --name " + opts[:font_name] : ""
        hash = opts[:file_hash] ? "" : " --nohash"
        cmd = "fontforge -script #{Fontcustom::Util.gem_lib_path}/scripts/generate.py #{opts[:input][:vectors]} #{opts[:output][:fonts] + name + hash} 2>&1"

        output = `#{cmd}`.split("\n")
        @json = output[3] # JSON
        if @json == 'Warning: Font contained no glyphs'
          @json = output[4]
          output = output[5..-1] # Strip fontforge message
        else
          @json = output[3]
          output = output[4..-1] # Strip fontforge message
        end

        if opts[:debug]
          shell.say "DEBUG: (raw output from fontforge)"
          shell.say output
        end

        unless $?.success?
          raise Fontcustom::Error, "Compilation failed unexpectedly. Check your options and try again with --debug get more details."
        end
      end

      def collect_data
        @json = JSON.parse(@json, :symbolize_names => true)
        @data.merge! @json
        @data[:glyphs].map! { |glyph| glyph.gsub(/\W/, "-") }
        @data[:fonts].each do |font|
          @data[:fonts_previous] << File.join(@opts[:output][:fonts], font)
        end
      end

      def announce_files
        if opts[:verbose]
          path = opts[:output][:fonts].sub(opts[:project_root], '')
          @data[:fonts].each do |file| 
            shell.say_status(:create, File.join(path, file)[1..-1])
          end
        end
      end

      def save_data
        json = JSON.pretty_generate @data
        file = File.join(opts[:project_root], ".fontcustom-data")
        Fontcustom::Util.clear_file(file)
        append_to_file file, json, :verbose => opts[:verbose]
      end
    end
  end
end
