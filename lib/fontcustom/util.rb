require "yaml"

module Fontcustom
  class Util
    DEFAULT_OPTIONS = {
      :input => Dir.pwd,
      :output => false, # used to assign default, if necessary 
      :config => false,
      :templates => [:css, :demo], 
      :file_name => "fontcustom",
      :file_hash => true,
      :css_font_path => "",
      :css_selector_prefix => ".icon-",
      :scss => false,
      :demo => true,
      :debug => false,
      :verbose => true
    }

    DATA_MODEL = {
      :files => [],
      :file_name => "",
      :icons => []
    }

    class << self 
      def check_fontforge
        if `which fontforge` == ""
          raise Fontcustom::Error, "Please install fontforge first. Visit http://fontcustom.com for more details."
        end
      end

      # Priority: Passed args > config file > default
      def collect_options(args = {})
        options = DEFAULT_OPTIONS.clone
        options[:config] = get_config_path(args)
        args.delete :config # don't overwrite #get_config_path

        if options[:config]
          config = YAML.load File.open(options[:config])
          if config.is_a? Hash
            config = config.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
            options.merge! config
          end
        end

        options.merge! args
        options[:output] ||= File.join(options[:input], "fontcustom")
        options[:templates] = get_template_paths(options[:templates])
        options[:file_name] = options[:file_name].strip.downcase.gsub(/\W/, '-') 
        options
      end

      # Checks options[:config], options[:input], and pwd
      def get_config_path(options)
        if options[:config] && File.exists?(options[:config])
          options[:config] 
        elsif options[:input] && File.exists?(File.join(options[:input], "fontcustom.yml"))
          File.join(options[:input], "fontcustom.yml")
        elsif File.exists?(File.join(Dir.pwd, "fontcustom.yml"))
          File.join(Dir.pwd, "fontcustom.yml") 
        else
          false
        end
      end

      # Could arguably belong in Generator::Template, however, it's nice to
      # be able to catch template errors before any generator runs.
      def get_template_paths(templates)
        templates = templates.map do |template|
          case template
          when :css
            File.join gem_lib_path, "templates", "fontcustom.css"
          when :scss
            File.join gem_lib_path, "templates", "_fontcustom.scss"
          when :demo
            File.join gem_lib_path, "templates", "fontcustom.html"
          else
            if template.is_a?(String) && File.exists?(template)
              template
            else
              raise Fontcustom::Error, "We couldn't find your custom template: #{template}\nPlease double check and try again."
            end
          end
        end
      end

      def clear_file(file)
        File.open(file, "w") {}
      end

      def gem_lib_path
        File.expand_path(File.join(File.dirname(__FILE__)))
      end
    end
  end
end
