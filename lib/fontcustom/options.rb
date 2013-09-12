require "yaml"
require "thor/shell"
require "thor/shell/basic"
require "thor/shell/color"
require "thor/core_ext/hash_with_indifferent_access"
require "fontcustom/util"

module Fontcustom
  class Options
    include Util

    attr_reader :project_root, :input, :output, :config, :data_cache, :templates,
      :font_name, :file_hash, :css_prefix, :preprocessor_path, :skip_first, :debug, :verbose

    def initialize(options = {})
      check_fontforge

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
        path = File.expand_path File.join(@cli_options[:project_root], @cli_options[:config])

        # :config is the path to fontcustom.yml
        if File.exists?(path) && ! File.directory?(path)
          path

        # :config is a dir containing fontcustom.yml
        elsif File.exists? File.join(path, "fontcustom.yml")
          File.join path, "fontcustom.yml"

        else
          raise Fontcustom::Error, "The configuration file was not found. Check #{relative_to_root(path)} and try again."
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
        say_message :status, "Loading configuration file at #{relative_to_root(@config)}."
        begin
          config = YAML.load File.open(@config)
          @config_options = config if config # empty file returns false
        rescue Exception => e
          raise Fontcustom::Error, "The configuration file failed to load. Message: #{e.message}"
        end
      else
        say_message :status, "No configuration file set. Using defaults."
      end
    end

    def merge_options
      @cli_options.delete_if { |key, val| val == DEFAULT_OPTIONS[key] }

      options = DEFAULT_OPTIONS.dup
      options = options.merge @config_options
      options = options.merge @cli_options
      remove_instance_variable :@config_options
      remove_instance_variable :@cli_options

      # :config is excluded since it's already been set
      keys = %w|project_root input output data_cache templates font_name file_hash css_prefix preprocessor_path skip_first debug verbose|
      keys.each { |key| instance_variable_set("@#{key}", options[key]) }

      @font_name = @font_name.strip.gsub(/\W/, '-')
    end

    def set_data_path
      @data_cache = if ! @data_cache.nil?
        File.expand_path File.join(@project_root, @data_cache)
      elsif @config
        File.join File.dirname(@config), '.fontcustom-data'
      else
        File.join @project_root, '.fontcustom-data'
      end
    end

    def set_input_paths
      if @input.is_a? Hash
        @input = Thor::CoreExt::HashWithIndifferentAccess.new @input

        if @input.has_key? "vectors"
          @input[:vectors] = File.expand_path File.join(@project_root, @input[:vectors])
          unless File.directory? input[:vectors]
            raise Fontcustom::Error, "INPUT[\"vectors\"] should be a directory. Check #{relative_to_root(input[:vectors])} and try again."
          end
        else
          raise Fontcustom::Error, "INPUT (as a hash) should contain a \"vectors\" key."
        end

        if @input.has_key? "templates"
          @input[:templates] = File.expand_path File.join(@project_root, @input[:templates])
          unless File.directory? @input[:templates]
            raise Fontcustom::Error, "INPUT[\"templates\"] should be a directory. Check #{relative_to_root(input[:templates])} and try again."
          end
        else
          @input[:templates] = @input[:vectors]
        end
      elsif @input.is_a? String
        input = File.expand_path File.join(@project_root, @input)
        unless File.directory? input
          raise Fontcustom::Error, "INPUT (as a string) should be a directory. Check #{relative_to_root(input)} and try again."
        end
        @input = Thor::CoreExt::HashWithIndifferentAccess.new({
          :vectors => input,
          :templates => input
        })
      end

      if Dir[File.join(@input[:vectors], "*.{svg,eps}")].empty?
        raise Fontcustom::Error, "#{relative_to_root(@input[:vectors])} doesn't contain any vectors (*.svg or *.eps files)."
      end
    end

    def set_output_paths
      if @output.is_a? Hash
        @output = Thor::CoreExt::HashWithIndifferentAccess.new @output
        raise Fontcustom::Error, "OUTPUT (as a hash) should contain a \"fonts\" key." unless @output.has_key? "fonts"

        @output.each do |key, val|
          @output[key] = File.expand_path File.join(@project_root, val)
          if File.exists?(val) && ! File.directory?(val)
            raise Fontcustom::Error, "OUTPUT[\"#{key}\"] should be a directory, not a file. Check #{relative_to_root(val)} and try again."
          end
        end

        @output[:css] ||= @output[:fonts]
        @output[:preview] ||= @output[:fonts]
      else
        if @output.is_a? String
          output = File.expand_path File.join(@project_root, @output)
          if File.exists?(output) && ! File.directory?(output)
            raise Fontcustom::Error, "OUTPUT should be a directory, not a file. Check #{relative_to_root(output)} and try again."
          end
        else
          output = File.join @project_root, @font_name
          say_message :status, "All generated files will be added into `#{relative_to_root(output)}/` by default."
        end

        @output = Thor::CoreExt::HashWithIndifferentAccess.new({
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
    def set_template_paths
      # ensure that preview has plain stylesheet to reference
      @templates << "preview-css" if @templates.include?("preview") && ! @templates.include?("preview-css")

      template_path = File.join Fontcustom.gem_lib, "templates"

      @templates = @templates.map do |template|
        case template
        when "preview"
          File.join template_path, "fontcustom-preview.html"
        when "preview-css"
          File.join template_path, "fontcustom-preview.css"
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
          path = File.expand_path File.join(@input[:templates], template)
          raise Fontcustom::Error, "The custom template at #{relative_to_root(path)} does not exist." unless File.exists? path
          path
        end
      end
    end
  end
end
