require "json"
require "thor"
require "thor/group"
require "thor/actions"

module Fontcustom
  module Generator
    class Font < Thor::Group
      include Thor::Actions

      # Instead of passing each option individually we're passing the entire options hash as an argument.
      # This is DRYier, easier to maintain.
      argument :opts

      def check_input
        if ! File.directory? opts[:input]
          raise Fontcustom::Error, "#{opts[:input]} doesn't exist or isn't a directory."
        elsif Dir[File.join(opts[:input], "*.{svg,eps}")].empty?
          raise Fontcustom::Error, "#{opts[:input]} doesn't contain any vectors (*.svg or *.eps files)."
        end
      end

      def check_output
        if File.exists? File.join(opts[:output], ".fontcustom-data")
          # Skip ahead, everything is in order
        elsif File.exists?(opts[:output]) && ! File.directory?(opts[:output])
          raise Fontcustom::Error, "#{opts[:output]} already exists but isn't a directory."
        else
          # creates opts[:output] as well
          add_file File.join(opts[:output], ".fontcustom-data"), :verbose => opts[:verbose]
        end
      end

      def get_data
        # file has already been verified/created
        data = File.read File.join(opts[:output], ".fontcustom-data")
        data = JSON.parse(data, :symbolize_names => true) unless data.empty?
        @data = data.is_a?(Hash) ? data : Fontcustom::DATA_MODEL.dup
      rescue JSON::ParserError
        raise Fontcustom::Error, "The .fontcustom-data file in #{opts[:output]} is corrupted. Fix the JSON or delete the file to start from scratch."
      end

      def reset_output
        return if @data[:fonts].empty?
        begin
          deleted = []
          @data[:fonts].each do |file|
            remove_file File.join(opts[:output], file), :verbose => opts[:verbose]
            deleted << file
          end
        ensure
          @data[:fonts] = @data[:fonts] - deleted
          json = JSON.pretty_generate @data
          file = File.join(opts[:output], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, json, :verbose => false # clear data file silently
        end
      end

      def generate
        # TODO align option naming conventions with python script
        # TODO remove name arg if default is already set in python (or rm from python)
        name = opts[:font_name] ? " --name " + opts[:font_name] : ""
        hash = opts[:file_hash] ? "" : " --nohash"
        cmd = "fontforge -script #{Fontcustom::Util.gem_lib_path}/scripts/generate.py #{opts[:input]} #{opts[:output] + name + hash} 2>&1"

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

        unless output.empty? # correct output should be []
          raise Fontcustom::Error, "Compilation failed unexpectedly. Check your options and try again with --debug get more details."
        end
      end

      def collect_data
        @json = JSON.parse(@json, :symbolize_names => true)
        @data.merge! @json
        @data[:glyphs].map! { |glyph| glyph.gsub(/\W/, "-").downcase }
      end

      def announce_files
        if opts[:verbose]
          @data[:fonts].each { |file| shell.say_status(:create, File.join(opts[:output], file)) }
        end
      end

      def save_data
        json = JSON.pretty_generate @data
        file = File.join(opts[:output], ".fontcustom-data")
        Fontcustom::Util.clear_file(file)
        append_to_file file, json, :verbose => opts[:verbose]
      end
    end
  end
end
