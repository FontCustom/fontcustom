require "yaml"
require "thor/core_ext/hash_with_indifferent_access"

module Fontcustom
  class Util
    class << self
      def check_fontforge
        fontforge = `which fontforge`
        if fontforge == "" || fontforge == "fontforge not found"
          raise Fontcustom::Error, "Please install fontforge first. Visit http://fontcustom.com for more details."
        end
      end

      # Converts all options into symbol-accessible hashes
      # Priority: Passed args > config file > default
      def collect_options(args = {})
        options = Fontcustom::DEFAULT_OPTIONS.clone
        options[:project_root] = args[:project_root] if args[:project_root]

        # Parse fontcustom.yml if it exists
        # Deletes :config so that it can't overwrite the output of .get_config_path
        options[:config] = args.delete(:config) if args[:config]
        options[:config] = get_config_path options

        if options[:config]
          begin
            config = YAML.load File.open(options[:config])
            options.merge! config
          rescue
            raise Fontcustom::Error, "I couldn't read your configuration file. Please check #{options[:config]} and try again."
          end
        end

        # Override with passed arguments
        args.delete(:input) unless args[:input] # allows nil input from CLI
        options.merge! args
        options[:font_name] = options[:font_name].strip.gsub(/\W/, '-')

        options[:input] = get_input_paths options
        options[:output] = get_output_paths options
        options[:templates] = get_templates options
        options
      end

      def get_config_path(options)
        if options[:config]
          config = File.expand_path File.join(options[:project_root], options[:config])

          # :config is the path to fontcustom.yml
          if File.exists?(config) && ! File.directory?(config)
            config

          # :config is a dir containing fontcustom.yml
          elsif File.exists? File.join(config, "fontcustom.yml")
            File.join config, "fontcustom.yml"

          else
            raise Fontcustom::Error, "I couldn't find your configuration file. Check #{config} and try again."
          end
        else
          # fontcustom.yml is in the project_root
          if File.exists? File.join(options[:project_root], "fontcustom.yml")
            File.join options[:project_root], "fontcustom.yml"

          # config/fontcustom.yml is in the project_root
          elsif File.exists? File.join(options[:project_root], "config", "fontcustom.yml")
            File.join options[:project_root], "config", "fontcustom.yml"

          else
            # TODO helpful warning that no config was found
            false
          end
        end
      end

      def get_input_paths(options)
        paths = if options[:input].is_a? Hash
          input = Thor::CoreExt::HashWithIndifferentAccess.new options[:input]
          raise Fontcustom::Error, "INPUT should be a string or a hash containing a \"vectors\" key." unless input[:vectors]

          input[:vectors] = File.expand_path File.join(options[:project_root], input[:vectors])
          raise Fontcustom::Error, "INPUT[\"vectors\"] should be a directory. Check #{input[:vectors]} and try again." unless File.directory? input[:vectors]

          if input[:templates]
            input[:templates] = File.expand_path File.join(options[:project_root], input[:templates])
            raise Fontcustom::Error, "INPUT[\"templates\"] should be a directory. Check #{input[:templates]} and try again." unless File.directory? input[:templates]
          else
            input[:templates] = input[:vectors]
          end
          input
        elsif options[:input].is_a? String
          input = File.join options[:project_root], options[:input]
          raise Fontcustom::Error, "INPUT should be a directory. Check #{input} and try again." unless File.directory? input
          Thor::CoreExt::HashWithIndifferentAccess.new({
            :vectors => input,
            :templates => input
          })
        end

        if Dir[File.join(paths[:vectors], "*.{svg,eps}")].empty?
          raise Fontcustom::Error, "#{paths[:vectors]} doesn't contain any vectors (*.svg or *.eps files)."
        end

        paths
      end

      def get_output_paths(options)
        if options[:output].is_a? Hash
          output = Thor::CoreExt::HashWithIndifferentAccess.new options[:output]
          raise Fontcustom::Error, "OUTPUT should be a string or a hash containing a \"fonts\" key." unless output[:fonts]

          output.each do |key, val|
            output[key] = File.expand_path File.join(options[:project_root], val)
          end

          output[:css] ||= output[:fonts]
          output[:preview] ||= output[:fonts]
          output
        else
          if options[:output].is_a? String
            output = File.expand_path File.join(options[:project_root], options[:output])
            raise Fontcustom::Error, "OUTPUT should be a directory, not a file. Check #{output} and try again." if File.exists?(output) && ! File.directory?(output)
          else
            # TODO friendly warning that we're defaulting to pwd/:font_name
            output = File.join options[:project_root], options[:font_name]
          end
          Thor::CoreExt::HashWithIndifferentAccess.new({
            :fonts => output,
            :css => output,
            :preview => output
          })
        end
      end

      # Translates shorthand to full path of packages templates, otherwise,
      # it checks input and pwd for the template.
      #
      # Could arguably belong in Generator::Template, however, it's nice to
      # be able to catch template errors before any generator runs.
      def get_templates(options)
        # ensure that preview has plain stylesheet to reference
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
            path = File.join options[:input][:templates], template
            raise Fontcustom::Error, "We couldn't find your custom template at #{path}. Double check and try again?" unless File.exists? path
            path
          end
        end
      end

      def gem_lib_path
        File.expand_path(File.join(File.dirname(__FILE__)))
      end
    end
  end
end
