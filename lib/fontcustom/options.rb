require 'yaml'
require 'pp'

module Fontcustom
  class Options
    include Utility

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
      check_template_paths
      print_debug if @options[:debug]
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
        path = @cli_options[:config]
        if File.exist?(path) && !File.directory?(path)
          path
        elsif File.exist? File.join(path, 'fontcustom.yml')
          File.join path, 'fontcustom.yml'
        else
          fail Fontcustom::Error, "No configuration file found at `#{path}`."
        end
      else
        if File.exist? 'fontcustom.yml'
          'fontcustom.yml'
        elsif File.exist? File.join('config', 'fontcustom.yml')
          File.join 'config', 'fontcustom.yml'
        else
          false
        end
      end
    end

    def load_config
      @config_options = {}
      if @cli_options[:config]
        begin
          config = YAML.load File.open(@cli_options[:config])
          if config # empty YAML returns false
            @config_options = symbolize_hash(config)
            say_message :debug, "Using settings from `#{@cli_options[:config]}`." if @cli_options[:debug] || @config_options[:debug]
          else
            say_message :warn, "`#{@cli_options[:config]}` was empty. Using defaults."
          end
        rescue Exception => e
          raise Fontcustom::Error, "Error parsing `#{@cli_options[:config]}`:\n#{e.message}"
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
      @options[:font_name] = @options[:font_name].strip.gsub(/\W/, '-')
    end

    def clean_css_selector
      unless @options[:css_selector].include? '{{glyph}}'
        fail Fontcustom::Error,
             "CSS selector `#{@options[:css_selector]}` should contain the \"{{glyph}}\" placeholder."
      end
      @options[:css_selector] = @options[:css_selector].strip.gsub(/[^&%=\[\]\.#\{\}""\d\w]/, '-')
    end

    def set_input_paths
      if @options[:input].is_a? Hash
        @options[:input] = symbolize_hash(@options[:input])
        if @options[:input].key? :vectors
          check_input @options[:input][:vectors]
        else
          fail Fontcustom::Error,
               'Input paths (assigned as a hash) should have a :vectors key. Check your options.'
        end

        if @options[:input].key? :templates
          check_input @options[:input][:templates]
        else
          @options[:input][:templates] = @options[:input][:vectors]
        end
      else
        if @options[:input]
          input = @options[:input]
        else
          input = '.'
          say_message :warn, 'No input directory given. Using present working directory.'
        end
        check_input input
        @options[:input] = { vectors: input, templates: input }
      end

      if Dir[File.join(@options[:input][:vectors], '*.svg')].empty?
        fail Fontcustom::Error, "`#{@options[:input][:vectors]}` doesn't contain any SVGs."
      end
    end

    def set_output_paths
      if @options[:output].is_a? Hash
        @options[:output] = symbolize_hash(@options[:output])
        unless @options[:output].key? :fonts
          fail Fontcustom::Error,
               'Output paths (assigned as a hash) should have a :fonts key. Check your options.'
        end

        @options[:output].each do |key, val|
          @options[:output][key] = val
          if File.exist?(val) && !File.directory?(val)
            fail Fontcustom::Error,
                 "Output `#{@options[:output][key]}` exists but isn't a directory. Check your options."
          end
        end

        @options[:output][:css] ||= @options[:output][:fonts]
        @options[:output][:preview] ||= @options[:output][:fonts]
      else
        if @options[:output].is_a? String
          output = @options[:output]
          if File.exist?(output) && !File.directory?(output)
            fail Fontcustom::Error,
                 "Output `#{output}` exists but isn't a directory. Check your options."
          end
        else
          output = @options[:font_name]
          say_message :debug, "Generated files will be saved to `#{output}/`." if @options[:debug]
        end

        @options[:output] = {
          fonts: output,
          css: output,
          preview: output
        }
      end
    end

    def check_template_paths
      @options[:templates].each do |template|
        next if %w(preview css scss scss-rails).include? template
        path = File.expand_path File.join(@options[:input][:templates], template) unless template[0] == '/'
        unless File.exist? path
          fail Fontcustom::Error,
               "Custom template `#{template}` wasn't found in `#{@options[:input][:templates]}/`. Check your options."
        end
      end
    end

    def check_input(dir)
      if !File.exist? dir
        fail Fontcustom::Error,
             "Input `#{dir}` doesn't exist. Check your options."
      elsif !File.directory? dir
        fail Fontcustom::Error,
             "Input `#{dir}` isn't a directory. Check your options."
      end
    end

    def print_debug
      message = line_break(16)
      message << @options.pretty_inspect.split("\n ").join(line_break(16))
      say_message :debug, "Using options:#{message}"
    end
  end
end
