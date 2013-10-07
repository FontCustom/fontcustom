require "yaml"
require "thor/shell"
require "thor/shell/basic"
require "thor/shell/color"
require "fontcustom/util"

module Fontcustom
  class Options
    include Util

    attr_reader :project_root, :input, :output, :config, :templates, :font_name, :css_prefix, :css_postfix, :data_cache, :preprocessor_path, :no_hash, :debug, :quiet, :skip_first 

    def initialize(options = {})
      check_fontforge
      options = symbolize_hash(options)

      # Overwrite example defaults (used in Thor's help) with real defaults, if unchanged
      EXAMPLE_OPTIONS.keys.each do |key|
        options.delete(key) if options[key] == EXAMPLE_OPTIONS[key]
      end
      @cli_options = DEFAULT_OPTIONS.dup.merge options

      @shell = Thor::Shell::Color.new
      set_options
    end

    private

    def set_options
      set_config_path
      load_config
      merge_options
      set_data_path
      set_input_paths
      set_output_paths
      set_template_paths
    end

    def set_config_path
      @config = if @cli_options[:config]
        path = expand_path @cli_options[:config]

        # :config is the path to fontcustom.yml
        if File.exists?(path) && ! File.directory?(path)
          path

        # :config is a dir containing fontcustom.yml
        elsif File.exists? File.join(path, "fontcustom.yml")
          File.join path, "fontcustom.yml"

        else
          raise Fontcustom::Error, "The configuration file wasn't found. Check `#{relative_to_root(path)}` and try again."
        end
      else
        # fontcustom.yml is in the project_root
        if File.exists? File.join(@cli_options[:project_root], "fontcustom.yml")
          File.join @cli_options[:project_root], "fontcustom.yml"

        # config/fontcustom.yml is in the project_root
        elsif File.exists? File.join(@cli_options[:project_root], "config", "fontcustom.yml")
          File.join @cli_options[:project_root], "config", "fontcustom.yml"

        else
          false
        end
      end
    end

    def load_config
      @config_options = {}
      if @config
        say_message :status, "Loading configuration file at `#{relative_to_root(@config)}`."
        begin
          config = YAML.load File.open(@config)
          if config # empty YAML returns false
            @config_options = symbolize_hash(config)
          else
            say_message :status, "Configuration file was empty. Using defaults."
          end
        rescue Exception => e
          raise Fontcustom::Error, "The configuration file failed to load. Message: #{e.message}"
        end
      else
        say_message :status, "No configuration file set. Generate one with `fontcustom config` to save your settings."
      end
    end

    def merge_options
      @cli_options.delete_if { |key, val| val == DEFAULT_OPTIONS[key] }

      options = DEFAULT_OPTIONS.dup
      options = options.merge @config_options
      options = options.merge symbolize_hash(@cli_options)
      remove_instance_variable :@config_options
      remove_instance_variable :@cli_options

      # :config is excluded since it's already been set
      keys = %w|project_root input output data_cache templates font_name css_prefix css_postfix preprocessor_path skip_first no_hash debug quiet|
      keys.each { |key| instance_variable_set("@#{key}", options[key.to_sym]) }

      @font_name = @font_name.strip.gsub(/\W/, "-")
    end

    def set_data_path
      @data_cache = if ! @data_cache.nil?
        expand_path @data_cache
      elsif @config
        File.join File.dirname(@config), ".fontcustom-data"
      else
        File.join @project_root, ".fontcustom-data"
      end
    end

    def set_input_paths
      if @input.is_a? Hash
        @input = symbolize_hash(@input)
        if @input.has_key? :vectors
          @input[:vectors] = expand_path @input[:vectors]
          unless File.directory? @input[:vectors]
            raise Fontcustom::Error, "INPUT[:vectors] should be a directory. Check `#{relative_to_root(@input[:vectors])}` and try again."
          end
        else
          raise Fontcustom::Error, "INPUT (as a hash) should contain a :vectors key."
        end

        if @input.has_key? :templates
          @input[:templates] = expand_path @input[:templates]
          unless File.directory? @input[:templates]
            raise Fontcustom::Error, "INPUT[:templates] should be a directory. Check `#{relative_to_root(@input[:templates])}` and try again."
          end
        else
          @input[:templates] = @input[:vectors]
        end
      else
        input = @input ? expand_path(@input) : @project_root
        unless File.directory? input
          raise Fontcustom::Error, "INPUT (as a string) should be a directory. Check `#{relative_to_root(input)}` and try again."
        end
        @input = { :vectors => input, :templates => input }
      end

      if Dir[File.join(@input[:vectors], "*.{svg,eps}")].empty?
        raise Fontcustom::Error, "`#{relative_to_root(@input[:vectors])}` doesn't contain any vectors (*.svg or *.eps files)."
      end
    end

    def set_output_paths
      if @output.is_a? Hash
        @output = symbolize_hash(@output)
        raise Fontcustom::Error, "OUTPUT (as a hash) should contain a :fonts key." unless @output.has_key? :fonts

        @output.each do |key, val|
          @output[key] = expand_path val
          if File.exists?(val) && ! File.directory?(val)
            raise Fontcustom::Error, "OUTPUT[:#{key.to_s}] should be a directory, not a file. Check `#{relative_to_root(val)}` and try again."
          end
        end

        @output[:css] ||= @output[:fonts]
        @output[:preview] ||= @output[:fonts]
      else
        if @output.is_a? String
          output = expand_path @output
          if File.exists?(output) && ! File.directory?(output)
            raise Fontcustom::Error, "OUTPUT should be a directory, not a file. Check `#{relative_to_root(output)}` and try again."
          end
        else
          output = File.join @project_root, @font_name
          say_message :status, "All generated files will be saved to `#{relative_to_root(output)}/`."
        end

        @output = {
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

      @templates = @templates.map do |template|
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
          template = File.expand_path File.join(@input[:templates], template) unless template[0] == "/"
          raise Fontcustom::Error, "The custom template at `#{relative_to_root(template)}` does not exist." unless File.exists? template
          template
        end
      end
    end
  end
end
