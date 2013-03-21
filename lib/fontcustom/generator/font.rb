require "thor/shell"

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

        run_script(cmd)
        save_output_data
        show_paths
      end

      private

      def run_script(cmd)
        `#{cmd}`
      end

      def save_output_data
        # TODO
        # read input for classnames
        # read output for hash
      end
      
      def show_paths
        # TODO
        path = @options.font_name
        shell = ::Thor::Shell::Color.new
        ["woff","ttf","eot","svg"].each do |type|
          shell.say_status(:create, path + "." + type)
        end
      end
    end
  end
end
