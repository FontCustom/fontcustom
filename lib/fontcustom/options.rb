require "yaml"

module Fontcustom
  class Options
    include Utility

    attr_accessor :options

    def initialize(cli_options = {})
      @manifest = cli_options[:manifest]
      @cli_options = symbolize_hash(cli_options)
      parse_options
    end

    private

    def parse_options
      overwrite_examples
      set_config_path
      load_config
      merge_options
      clean_font_name
      clean_css_selector
      set_input_paths
      set_output_paths
      set_template_paths
    end

    # We give Thor fake defaults to generate more useful help messages.
    # Here, we delete any CLI options that match those examples.
    # TODO There's *got* a be a cleaner way to customize Thor help messages.
    def overwrite_examples
      EXAMPLE_OPTIONS.keys.each do |key|
        @cli_options.delete(key) if @cli_options[key] == EXAMPLE_OPTIONS[key]
      end
      @cli_options = DEFAULT_OPTIONS.dup.merge @cli_options
    end

    def set_config_path
      @cli_options[:config] = if @cli_options[:config]
        path = expand_path @cli_options[:config]

        # :config is the path to fontcustom.yml
        if File.exists?(path) && ! File.directory?(path)
          path

        # :config is a dir containing fontcustom.yml
        elsif File.exists? File.join(path, "fontcustom.yml")
          File.join path, "fontcustom.yml"

        else
          raise Fontcustom::Error, "No configuration file found at `#{relative_path(path)}`."
        end
      else
        # fontcustom.yml is in the project_root
        if File.exists? File.join(project_root, "fontcustom.yml")
          File.join project_root, "fontcustom.yml"

        # config/fontcustom.yml is in the project_root
        elsif File.exists? File.join(project_root, "config", "fontcustom.yml")
          File.join project_root, "config", "fontcustom.yml"

        else
          false
        end
      end
    end

    def load_config
      @config_options = {}
      if @cli_options[:config]
        say_message :debug, "Using settings from `#{relative_path(@cli_options[:config])}`." if @cli_options[:debug]
        begin
          config = YAML.load File.open(@cli_options[:config])
          if config # empty YAML returns false
            @config_options = symbolize_hash(config)
          else
            say_message :warn, "`#{relative_path(@cli_options[:config])}` was empty. Using defaults."
          end
        rescue Exception => e
          raise Fontcustom::Error, "Error parsing `#{relative_path(@cli_options[:config])}`:\n#{e.message}"
        end
      end
    end

    # TODO validate keys
    def merge_options
      @cli_options.delete_if { |key, val| val == DEFAULT_OPTIONS[key] }
      @options = DEFAULT_OPTIONS.merge(@config_options).merge(@cli_options)
      @options.delete :manifest
    end

    def clean_font_name
      @options[:font_name] = @options[:font_name].strip.gsub(/\W/, "-")
    end

    def clean_css_selector
      unless @options[:css_selector].include? "{{glyph}}"
        raise Fontcustom::Error,
          "CSS selector `#{@options[:css_selector]}` should contain the \"{{glyph}}\" placeholder."
      end
      @options[:css_selector] = @options[:css_selector].strip.gsub(/[^\.#\{\}\w]/, "-")
    end

    def set_input_paths
      if @options[:input].is_a? Hash
        @options[:input] = symbolize_hash(@options[:input])
        if @options[:input].has_key? :vectors
          @options[:input][:vectors] = expand_path @options[:input][:vectors]
          check_input @options[:input][:vectors]
        else
          raise Fontcustom::Error,
            "Input paths (assigned as a hash) should have a :vectors key. Check your options."
        end

        if @options[:input].has_key? :templates
          @options[:input][:templates] = expand_path @options[:input][:templates]
          check_input @options[:input][:templates]
        else
          @options[:input][:templates] = @options[:input][:vectors]
        end
      else
        input = @options[:input] ? expand_path(@options[:input]) : project_root
        check_input input 
        @options[:input] = { :vectors => input, :templates => input }
      end

      if Dir[File.join(@options[:input][:vectors], "*.svg")].empty?
        raise Fontcustom::Error, "`#{relative_path(@options[:input][:vectors])}` doesn't contain any SVGs."
      end
    end

    def set_output_paths
      if @options[:output].is_a? Hash
        @options[:output] = symbolize_hash(@options[:output])
        unless @options[:output].has_key? :fonts
          raise Fontcustom::Error,
            "Output paths (assigned as a hash) should have a :fonts key. Check your options."
        end

        @options[:output].each do |key, val|
          @options[:output][key] = expand_path val
          if File.exists?(val) && ! File.directory?(val)
            raise Fontcustom::Error,
              "Output `#{relative_path(@options[:output][key])}` exists but isn't a directory. Check your options."
          end
        end

        @options[:output][:css] ||= @options[:output][:fonts]
        @options[:output][:preview] ||= @options[:output][:fonts]
      else
        if @options[:output].is_a? String
          output = expand_path @options[:output]
          if File.exists?(output) && ! File.directory?(output)
            raise Fontcustom::Error,
              "Output `#{relative_path(output)}` exists but isn't a directory. Check your options."
          end
        else
          output = File.join project_root, @options[:font_name]
          say_message :debug, "Generated files will be saved to `#{relative_path(output)}/`." if @options[:debug]
        end

        @options[:output] = {
          :fonts => output,
          :css => output,
          :preview => output
        }
      end
    end

    # Translates shorthand to full path of packages templates, otherwise,
    # it checks input and pwd for the template.
    #
    # Could arguably belong in Generator::Template, however, it's nice to
    # be able to catch template errors before any generator runs.
    def set_template_paths
      template_path = File.join Fontcustom.gem_lib, "templates"

      @options[:templates] = @options[:templates].map do |template|
        case template
        when "preview"
          File.join template_path, "fontcustom-preview.html"
        when "css"
          File.join template_path, "fontcustom.css"
        when "scss"
          File.join template_path, "_fontcustom.scss"
        when "scss-rails"
          File.join template_path, "_fontcustom-rails.scss"
        when "bootstrap"
          File.join template_path, "fontcustom-bootstrap.css"
        when "bootstrap-scss"
          File.join template_path, "_fontcustom-bootstrap.scss"
        when "bootstrap-ie7"
          File.join template_path, "fontcustom-bootstrap-ie7.css"
        when "bootstrap-ie7-scss"
          File.join template_path, "_fontcustom-bootstrap-ie7.scss"
        else
          template = File.expand_path File.join(@options[:input][:templates], template) unless template[0] == "/"
          unless File.exists? template
            raise Fontcustom::Error,
              "Custom template `#{relative_path(template)}` doesn't exist. Check your options."
          end
          template
        end
      end
    end

    def check_input(dir)
      if ! File.exists? dir
        raise Fontcustom::Error,
          "Input `#{relative_path(dir)}` doesn't exist. Check your options."
      elsif ! File.directory? dir
        raise Fontcustom::Error,
          "Input `#{relative_path(dir)}` isn't a directory. Check your options."
      end
    end
  end
end
