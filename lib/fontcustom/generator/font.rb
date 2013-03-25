require "thor/shell"
require "yaml"

module Fontcustom
  module Generator
    class Font
      attr_reader :base, :opts

      def initialize(base)
        @base = base
        @opts = base.opts
      end

      def start
        # TODO normalize naming conventions with python script
        # TODO remove name arg if default is already set in python (or rm from python)
        name = @opts.font_name ? " --name " + @opts.font_name : ""
        hash = @opts.hash ? "" : " --nohash"
        cmd = "fontforge -script #{Fontcustom::Base.gem_lib}/scripts/generate.py #{@opts.input_dir} #{@opts.output_dir + name + hash}"

        # TODO 
        # investigate using generate.py to swallow fontforge output 
        # and return YAML of classnames and hash
        cmd << " > /dev/null 2>&1" unless @opts.debug

        run_script(cmd)
        save_output_data
        show_paths
      end

      private

      def run_script(cmd)
        `#{cmd}`
      end

      def save_output_data
        @opts.icon_names = get_icon_names
        @opts.font_hash = get_font_hash
        update_data_file
      end

      def get_icon_names
        vectors = Dir[File.join(@opts.input_dir, "*.{svg,eps}")]
        vectors.map {|vector| File.basename(vector)[0..-5].gsub(/\W/, "-").downcase }
      end

      def get_font_hash
        path = Dir[File.join(@opts.output_dir, @opts.font_name + "*.ttf")].first
        name = File.basename path, ".ttf"
        name.sub(@opts.font_name + "-", "")
      end

      def update_data_file
        name = "#{@opts.font_name}-#{@opts.font_hash}."
        files = ["woff","ttf","eot","svg"].map { |ext| name + ext }
        @base.update_data_file files
      end
      
      def show_paths
        # TODO remove output_dir?
        path = File.join(@opts.output_dir, @opts.font_name + '-' + @opts.font_hash)
        ["woff","ttf","eot","svg"].each do |type|
          @base.shell.say_status(:create, path + "." + type)
        end
      end
    end
  end
end
