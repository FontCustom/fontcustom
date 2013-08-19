require "thor"
require "thor/actions"
require "fontcustom"
require "fontcustom/watcher"

module Fontcustom
  class CLI < Thor
    include Actions

    default_task :show_help

    # Actual defaults are stored in Fontcustom::DEFAULT_OPTIONS instead of Thor
    class_option :project_root, :aliases => "-r", :desc => "The base directory that all paths are relative to. Default: working directory"
    class_option :output, :aliases => "-o", :desc => "The directory that will receive generated files (created if it doesn't exist). Can be fine-tuned for arbitrary files if a configuration file is used. Default: PROJECT_ROOT/FONT_NAME/"
    class_option :config, :aliases => "-c", :desc => "Path to an optional configuration file. PROJECT_ROOT/fontcustom.yml and PROJECT_ROOT/config/fontcustom.yml will be loaded automatically." 
    class_option :templates, :aliases => "-t", :type => :array, :desc => "List of templates to compile alongside fonts. Default: 'css preview'", :enum => %w|preview css scss bootstrap bootstrap-scss bootstrap-ie7 bootstrap-ie7-scss|
    class_option :font_name, :aliases => "-n", :desc => "The font name used in your templates. Also determines the default OUTPUT directory name. Default: 'fontcustom'"
    class_option :file_hash, :aliases => "-h", :type => :boolean, :desc => "Option to generate font files with asset-busting hashes. Default: true"
    class_option :css_prefix, :aliases => "-p", :desc => "The prefix for each glyph's CSS class. Default: 'icon-'"
    class_option :preprocessor_font_path, :aliases => "-s", :desc => "The font path passed to CSS preprocessors (used instead of normal paths in preprocessed CSS templates). Default: none"
    class_option :debug, :aliases => "-d", :type => :boolean, :desc => "Display debug messages from fontforge. Default: false"
    class_option :verbose, :type => :boolean, :desc => "Display verbose messages. Default: true"

    # Required for Thor::Actions#template
    def self.source_root
      File.join Fontcustom::Util.gem_lib_path, "templates"
    end

    desc "compile [INPUT] [OPTIONS]", "Generates webfonts and templates from *.svg and *.eps files in INPUT. Default: working directory"
    def compile(input = nil)
      opts = options.merge :input => input
      opts = Fontcustom::Util.collect_options opts
      Fontcustom::Generator::Font.start [opts]
      Fontcustom::Generator::Template.start [opts]
    rescue Fontcustom::Error => e
      say_status :error, e.message
    end

    desc "watch [INPUT] [OPTIONS]", "Watches INPUT for changes and regenerates files automatically. Ctrl + C to stop. Default: working directory"
    method_option :skip_first, :aliases => "-s", :type => :boolean, :desc => "Skip the initial compile upon watching. Default: false"
    def watch(input = nil)
      opts = options.merge :input => input, :skip_first => !! options[:skip_first]
      opts = Fontcustom::Util.collect_options opts
      Fontcustom::Watcher.new(opts).watch
    rescue Fontcustom::Error => e
      say_status :error, e.message
    end

    desc "config [DIR]", "Generates an annotated configuration file (fontcustom.yml) in DIR. Default: working directory"
    def config(dir = Dir.pwd)
      template "fontcustom.yml", File.join(dir, "fontcustom.yml")
    end

    desc "hidden", "hidden", :hide => true
    method_option :version, :aliases => "-v", :type => :boolean, :default => false
    def show_help
      if options[:version]
        puts "fontcustom-#{Fontcustom::VERSION}"
      else
        help
      end
    end
  end
end
