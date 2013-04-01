require "thor"
require "fontcustom"

module Fontcustom
  class CLI < Thor
    # Actual defaults are stored in Fontcustom::DEFAULT_OPTIONS instead of Thor
    class_option :output, :aliases => "-o", :desc => "The output directory (will be created if it doesn't exist). Default: INPUT/fontcustom/"
    class_option :config, :aliases => "-c", :desc => "Path to fontcustom.yml. Default: `pwd`/fontcustom.yml and `pwd`/config/fontcustom.yml" 
    class_option :templates, :aliases => "-t", :type => :array, :desc => "A list of templates to compile after fonts are generated. Accepts 'css', 'scss', 'preview' or a path to any file of your choosing. Default: 'css' and 'preview'"
    class_option :font_name, :aliases => "--name -n", :desc => "The font name used in your templates (automatically normalized to lowercase spinal case). Default: 'fontcustom'"
    class_option :file_hash, :aliases => "--hash -h", :type => :boolean, :desc => "Generate font files with asset-busting hashes. Default: true"
    class_option :css_selector_prefix, :aliases => "--prefix -p", :desc => "The prefix for your icon CSS selectors. Default: '.icon-'"
    class_option :debug, :type => :boolean, :desc => "Display debug messages. Default: false"
    class_option :verbose, :aliases => "-v", :type => :boolean, :desc => "Display output messages. Default: true"

    desc "compile INPUT [options]", "Generates webfonts and CSS from *.svg and *.eps files in INPUT."
    def compile(input)
      options.merge! :input => input
      options = Fontcustom::Util.collect_options options
      Fontcustom::Generator::Font.start [options]
      Fontcustom::Generator::Template.start [options]
    end

    desc "watch INPUT [options]", "Watches INPUT for changes and regenerates webfonts and CSS automatically. Ctrl + C to stop."
    def watch(input)
    end
  end
end
