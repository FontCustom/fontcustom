require "thor"
require "thor/actions"
require "fontcustom"
require "fontcustom/watcher"

module Fontcustom
  class CLI < Thor
    include Utility

    default_task :show_help

    class_option :output, :aliases => "-o", :type => :string,
      :desc => "Where generated files are saved. Set different locations for different file types via a configuration file.",
      :default => EXAMPLE_OPTIONS[:output]

    class_option :config, :aliases => "-c", :type => :string,
      :desc => "Optional path to a configuration file.",
      :default => EXAMPLE_OPTIONS[:config]

    class_option :templates, :aliases => "-t", :type => :array,
      :desc => "Space-delinated list of files to generate alongside fonts. Use stock templates or choose your own.",
      :enum => %w|preview css scss scss-rails|,
      :default => EXAMPLE_OPTIONS[:templates]

    class_option :font_name, :aliases => %w|--name -n|, :type => :string,
      :desc => "The font's name. Also determines the file names of generated templates.",
      :default => DEFAULT_OPTIONS[:font_name]

    class_option :font_design_size, :aliases => %s|--size -s|, :type => :numeric,
      :desc => "Size (in pica points) for which this font is designed.",
      :default => DEFAULT_OPTIONS[:font_design_size]

    class_option :font_em, :aliases => %w|--em -e|, :type => :numeric,
      :desc => "The em size. Setting this will scale the entire font to the given size.",
      :default => DEFAULT_OPTIONS[:font_em]

    class_option :font_ascent, :aliases => %w|--ascent -a|, :type => :numeric,
      :desc => "The font's ascent. Used to calculate the baseline.",
      :default => DEFAULT_OPTIONS[:font_ascent]

    class_option :font_descent, :aliases => %w|--descent -d|, :type => :numeric,
      :desc => "The font's descent. Used to calculate the baseline.",
      :default => DEFAULT_OPTIONS[:font_descent]

    class_option :css_selector, :aliases => %w|--selector -S|, :type => :string,
      :desc => "Format of CSS selectors. \"{{glyph}}\" is substituted for the glyph name.",
      :default => DEFAULT_OPTIONS[:css_selector]

    class_option :preprocessor_path, :aliases => %w|--prepath -p|, :type => :string,
      :desc => "For Rails and Compass templates, set this as the relative path from your compiled CSS to your font output directory."

    class_option :autowidth, :aliases => "-A", :type => :boolean,
      :desc => "Horizontally fit glyphs to their individual vector widths."

    class_option :no_hash, :aliases => "-h", :type => :boolean,
      :desc => "Generate fonts without asset-busting hashes."

    class_option :base64, :aliases => "-b", :type => :boolean,
      :desc => "Encode WOFF fonts into the generated CSS."

    class_option :debug, :aliases => "-D", :type => :boolean,
      :desc => "Display (possibly useful) debugging messages."

    class_option :force, :aliases => "-F", :type => :boolean,
      :desc => "Forces compilation, even if inputs have not changed."

    class_option :single_quotes, :aliases => %w|--signle-quotes -Q|, :type => :boolean,
      :desc => "Use single quotes in generated CSS and SCSS templates"

    class_option :css3, :type => :boolean,
      :desc => "Ensure CSS3 compliant css/scss"

    class_option :quiet, :aliases => "-q", :type => :boolean,
      :desc => "Hide status messages."

    # Required for Thor::Actions#template
    def self.source_root
      File.join Fontcustom.gem_lib, "templates"
    end

    desc "compile [INPUT] [OPTIONS]", "Generates webfonts and templates from *.svg files in INPUT. Default: `pwd`"
    def compile(input = nil)
      Base.new(options.merge(:input => input)).compile
    rescue Fontcustom::Error => e
      say_status :error, e.message, :red
      puts e.backtrace.join("\n") if options[:debug]
    end

    desc "watch [INPUT] [OPTIONS]", "Watches INPUT for changes and regenerates files automatically. Ctrl + C to stop. Default: `pwd`"
    method_option :skip_first, :type => :boolean,
      :desc => "Skip the initial compile upon watching.",
      :default => false
    def watch(input = nil)
      say "Font Custom is watching your icons. Press Ctrl + C to stop.", :yellow unless options[:quiet]
      opts = options.merge :input => input, :skip_first => !! options[:skip_first]
      Watcher.new(opts).watch
    rescue Fontcustom::Error => e
      say_status :error, e.message, :red
    end

    desc "config [DIR]", "Generates a starter configuration file (fontcustom.yml) in DIR. Default: `pwd`"
    def config(dir = Dir.pwd)
      template "fontcustom.yml", File.join(dir, "fontcustom.yml")
    end

    desc "hidden", "hidden", :hide => true
    method_option :version, :aliases => "-v", :type => :boolean, :default => false
    def show_help
      if options[:version]
        puts "fontcustom-#{VERSION}"
      else
        help
      end
    end
  end
end
