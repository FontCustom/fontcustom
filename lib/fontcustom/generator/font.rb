require "yaml"
require "thor/group"
require "thor/actions"

module Fontcustom
  module Generator
    class Font < Thor::Group
      include Thor::Actions

      # Instead of passing each option individually we're passing the entire option hash as an argument. 
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
          add_file File.join(opts[:output], ".fontcustom-data") 
        end
      end

      def get_data
        data = File.join(opts[:output], ".fontcustom-data")
        data = YAML.load(File.open(data)) if File.exists? data
        @data = data.is_a?(Hash) ? data : Fontcustom::Util::DATA_MODEL.dup
      end

      def reset_output
        return unless @data[:files]
        begin
          deleted = []
          @data[:files].each do |file| 
            remove_file File.join(opts[:output], file)
            deleted << file
          end
        ensure
          @data[:files] = @data[:files] - deleted
          yaml = @data.to_yaml.sub("---\n", "")
          file = File.join(opts[:output], ".fontcustom-data")
          Fontcustom::Util.clear_file(file)
          append_to_file file, yaml, :verbose => false # clear data file silently
        end
      end
      
      def generate
        # TODO align option naming conventions with python script
        # TODO remove name arg if default is already set in python (or rm from python)
        name = opts[:file_name] ? " --name " + opts[:file_name] : ""
        hash = opts[:file_hash] ? "" : " --nohash"
        cmd = "fontforge -script #{Fontcustom::Util.gem_lib_path}/scripts/generate.py #{opts[:input]} #{opts[:output] + name + hash}"

        # TODO use generate.py to swallow fontforge output 
        cmd << " > /dev/null 2>&1" unless opts[:debug]

        begin
          `#{cmd}`
        rescue
          raise Fontcustom::Error, "The compilation failed unexpectedly. Check your options and try again with --debug get more details."
        end
      end

      # TODO move this into generate.py
      def collect_data
        @data[:icons] = Dir[File.join(opts[:input], "*.{svg,eps}")]
        @data[:icons].map! { |vector| File.basename(vector)[0..-5].gsub(/\W/, "-").downcase }
        @data[:file_name] = if opts[:hash]
                              opts[:file_name] 
                            else
                              ttf = Dir[File.join(opts[:output], opts[:file_name] + "*.ttf")].first
                              File.basename ttf, ".ttf"
                            end

        files = ["woff","ttf","eot","svg"].map { |ext| @data[:file_name] + '.' + ext }
        @data[:files] = @data[:files] + files
      end

      def announce_files
        @data[:files].each { |file| shell.say_status(:create, File.join(opts[:output], file)) }
      end

      def save_data
        yaml = @data.to_yaml.sub("---\n", "")
        file = File.join(opts[:output], ".fontcustom-data")
        Fontcustom::Util.clear_file(file)
        append_to_file file, yaml
      end
    end
  end
end
