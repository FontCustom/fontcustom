require "yaml"

module Fontcustom
  class Util
    class << self 
      def check_fontforge
        if `which fontforge` == ""
          raise Fontcustom::Error, "Please install fontforge first. Visit http://fontcustom.com for more details."
        end
      end

      # Converts all options into symbol-accessible hashes
      # Priority: Passed args > config file > default
      def collect_options(args = {})
        options = Fontcustom::DEFAULT_OPTIONS.clone
        args = args.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

        options[:input] = args[:input] if args[:input]
        options[:config] = args[:config] if args[:config]
        args.delete :config # don't overwrite the return value of #get_config_path
        options[:config] = get_config_path options

        if options[:config]
          config = YAML.load File.open(options[:config])
          if config.is_a? Hash
            config = config.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
            options.merge! config
          end
        end

        options.merge! args
        options[:output] ||= File.join(options[:input], "fontcustom")
        options[:templates] = get_template_paths options
        options[:font_name] = options[:font_name].strip.downcase.gsub(/\W/, '-') 
        options
      end

      # passed path > input
      def get_config_path(options)
        if options[:config] && File.directory?(options[:config]) && File.exists?(File.join(options[:config], "fontcustom.yml"))
          File.join options[:config], "fontcustom.yml"
        elsif options[:config] && File.exists?(options[:config]) 
          options[:config]
        elsif File.exists? File.join(options[:input], "fontcustom.yml")
          File.join options[:input], "fontcustom.yml"
        else
          false
        end
      end

      # Translates shorthand to full path of packages templates, otherwise,
      # it checks input and pwd for the template.
      #
      # Could arguably belong in Generator::Template, however, it's nice to
      # be able to catch template errors before any generator runs.
      def get_template_paths(options)
        options[:templates] << "css" if options[:templates].include?("preview") && ! options[:templates].include?("css")
        options[:templates].map do |template|
          case template
          when "preview"
            File.join gem_lib_path, "templates", "fontcustom-preview.html"
          when "css"
            File.join gem_lib_path, "templates", "fontcustom.css"
          when "scss"
            File.join gem_lib_path, "templates", "_fontcustom.scss"
          when "bootstrap"
            File.join gem_lib_path, "templates", "fontcustom-bootstrap.css"
          when "bootstrap-scss"
            File.join gem_lib_path, "templates", "_fontcustom-bootstrap.scss"
          when "bootstrap-ie7"
            File.join gem_lib_path, "templates", "fontcustom-bootstrap-ie7.css"
          when "bootstrap-ie7-scss"
            File.join gem_lib_path, "templates", "_fontcustom-bootstrap-ie7.scss"
          else
            if File.exists?(template)
              template
            elsif File.exists?(File.join(options[:input], template))
              File.join options[:input], template
            else
              raise Fontcustom::Error, "We couldn't find your custom template #{template}. Double check and try again?"
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
