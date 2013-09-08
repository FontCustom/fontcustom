require "yaml"
require "thor/shell"
require "thor/shell/basic"
require "thor/shell/color"
require "thor/core_ext/hash_with_indifferent_access"
require "fontcustom/util"

module Fontcustom
  class Options
    include Util

    def initialize
      @shell = Thor::Shell::Color.new
      @opts = {} # required for Fontcustom::Util
    end

    # Converts all options into symbol-accessible hashes
    # Priority: Passed args > config file > default
    def collect_options(args = {})
      options = Fontcustom::DEFAULT_OPTIONS.clone
      options[:project_root] = args[:project_root] if args[:project_root]

      # Parse fontcustom.yml if it exists
      # Deletes :config so that it can't overwrite the output of .get_config_path
      options[:config] = args.delete(:config) if args[:config]
      @opts = options # TODO 
      options[:config] = get_config_path options
      @opts = options # TODO 

      if options[:config]
        say_message :status, "Loading configuration file at #{relative_to_root(options[:config])}."
        begin
          config = YAML.load File.open(options[:config])
          if config
            options.merge! config
            @opts = options # TODO 
          else
            say_message :warning, "The configuration file was empty. No changes made."
          end
        rescue Exception => e
          raise Fontcustom::Error, "The configuration file failed to load. Message: #{e.message}"
        end
      end

      options[:data] = if args[:data]
                         File.expand_path File.join(options[:project_root], args.delete(:data))
                       elsif options[:config]
                         File.join File.dirname(options[:config]), '.fontcustom-data'
                       else
                         File.join options[:project_root], '.fontcustom-data'
                       end
      @opts = options # TODO 

      # Override with CLI arguments
      args.delete(:input) if args[:input].nil? # Empty CLI commands pass :input as nil 
      options.merge! args
      options[:font_name] = options[:font_name].strip.gsub(/\W/, '-')
      @opts = options # TODO 

      options[:input] = get_input_paths options
      @opts = options # TODO 
      options[:output] = get_output_paths options
      @opts = options # TODO 
      options[:templates] = get_templates options
      @opts = options # Temporary measure to give store options for Util
      options
    end

    def get_config_path(options)
      @opts = options
      if options[:config]
        config = File.expand_path File.join(options[:project_root], options[:config])

        # :config is the path to fontcustom.yml
        if File.exists?(config) && ! File.directory?(config)
          config

        # :config is a dir containing fontcustom.yml
        elsif File.exists? File.join(config, "fontcustom.yml")
          File.join config, "fontcustom.yml"

        else
          raise Fontcustom::Error, "The configuration file was not found. Check #{relative_to_root(options[:config])} and try again."
        end
      else
        # fontcustom.yml is in the project_root
        if File.exists? File.join(options[:project_root], "fontcustom.yml")
          File.join options[:project_root], "fontcustom.yml"

        # config/fontcustom.yml is in the project_root
        elsif File.exists? File.join(options[:project_root], "config", "fontcustom.yml")
          File.join options[:project_root], "config", "fontcustom.yml"

        else
          false
        end
      end
    end

    def get_input_paths(options)
      @opts = options
      paths = if options[:input].is_a? Hash
        input = Thor::CoreExt::HashWithIndifferentAccess.new options[:input]
        raise Fontcustom::Error, "INPUT (as a hash) should contain a \"vectors\" key." unless input[:vectors]

        input[:vectors] = File.expand_path File.join(options[:project_root], input[:vectors])
        raise Fontcustom::Error, "INPUT[\"vectors\"] should be a directory. Check #{relative_to_root(input[:vectors])} and try again." unless File.directory? input[:vectors]

        if input[:templates]
          input[:templates] = File.expand_path File.join(options[:project_root], input[:templates])
          raise Fontcustom::Error, "INPUT[\"templates\"] should be a directory. Check #{relative_to_root(input[:templates])} and try again." unless File.directory? input[:templates]
        else
          input[:templates] = input[:vectors]
        end
        input
      elsif options[:input].is_a? String
        input = File.join options[:project_root], options[:input]
        raise Fontcustom::Error, "INPUT (as a string) should be a directory. Check #{relative_to_root(input)} and try again." unless File.directory? input
        Thor::CoreExt::HashWithIndifferentAccess.new({
          :vectors => input,
          :templates => input
        })
      end

      if Dir[File.join(paths[:vectors], "*.{svg,eps}")].empty?
        raise Fontcustom::Error, "#{relative_to_root(paths[:vectors])} doesn't contain any vectors (*.svg or *.eps files)."
      end

      paths
    end

    def get_output_paths(options)
      @opts = options
      if options[:output].is_a? Hash
        output = Thor::CoreExt::HashWithIndifferentAccess.new options[:output]
        raise Fontcustom::Error, "OUTPUT (as a hash) should contain a \"fonts\" key." unless output[:fonts]

        output.each do |key, val|
          output[key] = File.expand_path File.join(options[:project_root], val)
          raise Fontcustom::Error, "OUTPUT[\"#{key}\"] should be a directory, not a file. Check #{relative_to_root(val)} and try again." if File.exists?(val) && ! File.directory?(val)
        end

        output[:css] ||= output[:fonts]
        output[:preview] ||= output[:fonts]
        output
      else
        if options[:output].is_a? String
          output = File.expand_path File.join(options[:project_root], options[:output])
          raise Fontcustom::Error, "OUTPUT should be a directory, not a file. Check #{relative_to_root(output)} and try again." if File.exists?(output) && ! File.directory?(output)
        else
          output = File.join options[:project_root], options[:font_name]
          say_message :status, "All generated files will be added into #{relative_to_root(output)} by default."
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
      @opts = options
      # ensure that preview has plain stylesheet to reference
      options[:templates] << "css" if options[:templates].include?("preview") && ! options[:templates].include?("css")
      template_path = File.join Fontcustom.gem_lib, "templates"

      options[:templates].map do |template|
        case template
        when "preview"
          File.join template_path, "fontcustom-preview.html"
        when "css"
          File.join template_path, "fontcustom.css"
        when "scss"
          File.join template_path, "_fontcustom.scss"
        when "bootstrap"
          File.join template_path, "fontcustom-bootstrap.css"
        when "bootstrap-scss"
          File.join template_path, "_fontcustom-bootstrap.scss"
        when "bootstrap-ie7"
          File.join template_path, "fontcustom-bootstrap-ie7.css"
        when "bootstrap-ie7-scss"
          File.join template_path, "_fontcustom-bootstrap-ie7.scss"
        else
          path = File.join options[:input][:templates], template
          raise Fontcustom::Error, "The custom template at #{relative_to_root(path)} does not exist." unless File.exists? path
          path
        end
      end
    end
  end
end
