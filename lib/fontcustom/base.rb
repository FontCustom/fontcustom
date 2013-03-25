require "yaml"
require "thor"
require "thor/actions"

module Fontcustom
  class Base < Thor
    include Thor::Actions

    # Using @opts so we don't collide with Thor's options
    attr_reader :opts
    
    # Required for Thor::Actions
    def self.source_root
      File.join(gem_lib, 'templates')
    end

    def self.gem_lib
      File.expand_path(File.join(File.dirname(__FILE__)))
    end

    # This block lets Thor know the following should not be public tasks.
    no_tasks do

      # Thor::Actions breaks when we define our own #initialize.
      # Using #load as a workaround for now.
      def load(options = {})
        @opts = Fontcustom::Options.new options

        # Thor::Actions will first look for templates in `pwd` before trying the input_dir and the gem defaults
        source_paths # assigns @source_paths
        @source_paths = @source_paths.unshift(Dir.pwd, @opts.input_dir)
      end

      def start
        verify_fontforge(`which fontforge`)
        verify_input_dir
        verify_output_dir

        # TODO do stuff
      end

      def verify_fontforge(which) # arg to simplify unit testing
        if which == ""
          error "Please install fontforge first."
        end
      end

      def verify_input_dir
        if ! File.directory? @opts.input_dir
          error "#{@opts.input_dir} doesn't exist or isn't a directory."
        elsif Dir[File.join(@opts.input_dir, "*.{svg,eps}")].empty?
          error "#{@opts.input_dir} doesn't contain any vectors (*.svg or *.eps files)."
        end
      end

      def verify_output_dir
        if File.directory? @opts.output_dir
          reset_output_dir
        elsif File.exists? @opts.output_dir
          error "#{@opts.output_dir} already exists but isn't a directory."
        end
      end

      def reset_output_dir
        data_file = File.join(@opts.output_dir, ".fontcustom-data")
        if File.exists? data_file
          paths = YAML.load_file data_file
          unless paths.empty?
            paths.each { |file| remove_file(file) }
            clear_data_file
          end
        else
          add_file data_file
        end
      end

      def clear_data_file
        data_file = File.join(@opts.output_dir, ".fontcustom-data")
        File.open(data_file, "w") {}
      end

      def update_data_file(files)
        data_file = File.join(@opts.output_dir, ".fontcustom-data")
        string = files.to_yaml.sub("---\n", "")
        append_to_file data_file, string 
      end

      def copy_template(template)
        # TODO check for presence of generated data first?
        # TODO update data file from here?
        ext = File.extname template
        destination = File.join @opts.output_dir, @opts.font_name + ext
        template(template, destination)
      end

      def error(msg)
        raise Thor::Error, msg
      end

      def gem_lib
        self.class.gem_lib
      end
    end
  end
end
