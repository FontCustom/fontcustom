require "thor"
require "thor/actions"
require "fontcustom"
require "fontcustom/watcher"

module Fontcustom
  class CLI < Thor
    include Thor::Actions

    # Actual defaults are stored in Fontcustom::DEFAULT_OPTIONS instead of Thor
    class_option :project_root, :aliases => "-r", :desc => "The base directory that all inputs and outputs are relative to. Default: working directory"
    class_option :output, :aliases => "-o", :desc => "The output directory (will be created if it doesn't exist). Default: PROJECT_ROOT/FONT_NAME/"
    class_option :config, :aliases => "-c", :desc => "Path to an optional configuration file. Files at PROJECT_ROOT/fontcustom.yml and PROJECT_ROOT/config/fontcustom.yml are loaded automatically." 
    class_option :templates, :aliases => "-t", :type => :array, :desc => "List of templates to compile alongside fonts. Accepts 'preview css scss bootstrap bootstrap-scss bootstrap-ie7 bootstrap-ie7-scss' or custom templates (advanced, run `fontcustom config` and read the example for more details). Default: 'css preview'"
    class_option :font_name, :aliases => "-n", :desc => "The font name used in your templates. Also determines the default OUTPUT directory name. Default: 'fontcustom'"
    class_option :file_hash, :aliases => "-h", :type => :boolean, :desc => "Option to generate font files with asset-busting hashes. Default: true"
    class_option :css_prefix, :aliases => "-p", :desc => "The prefix for each glyph's CSS class. Default: 'icon-'"
    class_option :font_face_path, :alias => "-f", :desc => "The http path used in @font-face declarations. Only used in .scss partials. Default: none"
    class_option :debug, :aliases => "-d", :type => :boolean, :desc => "Display debug messages from fontforge. Default: false"
    class_option :verbose, :aliases => "-v", :type => :boolean, :desc => "Display verbose messages. Default: true"

    # Required for Thor::Actions#template
    def self.source_root
      File.join Fontcustom::Util.gem_lib_path, "templates"
    end

    desc "compile [INPUT] [OPTIONS]", "Generates webfonts and CSS from *.svg and *.eps files in INPUT."
    def compile(input = nil)
      opts = options.merge :input => input
      opts = Fontcustom::Util.collect_options opts
      Fontcustom::Generator::Font.start [opts]
      Fontcustom::Generator::Template.start [opts]
    rescue Fontcustom::Error => e
      puts "ERROR: #{e.message}"
    end

    desc "watch [INPUT] [OPTIONS]", "Watches INPUT for changes and regenerates files automatically. Ctrl + C to stop."
    method_option :skip_first, :aliases => "-s", :type => :boolean, :desc => "Skip the initial compile upon watching. Default: false"
    def watch(input = nil)
      opts = options.merge :input => input, :skip_first => !! options[:skip_first]
      opts = Fontcustom::Util.collect_options opts
      Fontcustom::Watcher.new(opts).watch
    rescue Fontcustom::Error => e
      puts "ERROR: #{e.message}"
    end

    desc "config [DIR]", "Adds an annotated fontcustom.yml to DIR. Default: working directory"
    def config(dir = Dir.pwd)
      template "fontcustom.yml", File.join(dir, "fontcustom.yml")
    end

    desc "version", "Shows the version information."
    def version
      puts "fontcustom-#{Fontcustom::VERSION}"
    end
  end
end
