require "thor/shell"
require "yaml"

class Fontcustom
  module Generator
    class Font
      def initialize(options)
        @options = options
      end

      def start
        # TODO normalize naming conventions with python script
        # TODO remove name arg if default is already set in python (or rm from python)
        name = @options.font_name ? " --name " + @options.font_name : ""
        hash = @options.hash ? "" : " --nohash"
        cmd = "fontforge -script #{Fontcustom.root}/scripts/generate.py #{@options.input_dir} #{@options.output_dir + name + hash}"

        # TODO 
        # investigate using generate.py to swallow fontforge output 
        # and return YAML of classnames and hash
        cmd << " > /dev/null 2>&1" unless @options.debug

        run_script(cmd)
        save_output_data
        show_paths
      end

      private

      def run_script(cmd)
        `#{cmd}`
      end

      def save_output_data
        @options.icon_names = get_icon_names
        @options.font_hash = get_font_hash
        update_data_file
      end

      def get_icon_names
        vectors = Dir[File.join(@options.input_dir, "*.{svg,eps}")]
        vectors.map {|vector| File.basename(vector)[0..-5].gsub(/\W/, "-").downcase }
      end

      def get_font_hash
        path = Dir[File.join(@options.output_dir, @options.font_name + "*.ttf")].first
        name = File.basename path, ".ttf"
        name.sub(@options.font_name + "-", "")
      end

      def update_data_file
        name = "#{@options.font_name}-#{@options.font_hash}."
        files = ["woff","ttf","eot","svg"].map { |ext| name + ext }
        Fontcustom.update_data_file @options.output_dir, files
      end
      
      def show_paths
        path = File.join(@options.output_dir, @options.font_name + '-' + @options.font_hash)
        shell = ::Thor::Shell::Color.new
        ["woff","ttf","eot","svg"].each do |type|
          shell.say_status(:create, path + "." + type)
        end
      end
    end
  end
end
