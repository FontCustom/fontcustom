require 'yaml'

class Fontcustom
  class Options
    attr_reader :font_name, :font_path, :input_dir, :output_dir, :css_template, :css_prefix, :hash, :html, :debug

    def initialize(options = {})
      input_dir = options[:input_dir] || `pwd`.chomp
      config_file = options[:config_file] || File.join(input_dir, 'fontcustom.yml')
      if File.exists? config_file
        config = parse_config config_file
        options = config.merge! options # passed options overwrite config
      end

      @font_name = normalize_name options[:font_name]
      @font_path = options[:font_path] || './'
      @input_dir = input_dir
      @output_dir = options[:output_dir] || File.join(input_dir, 'fontcustom')
      @css_template = options[:css_template] || Fontcustom::Util.template('css')
      @css_prefix = options[:css_prefix] || '.icon-'
      @hash = options[:hash] || true
      @html = options[:html] || false
      @debug = options[:debug] || false
    end

    private

    def parse_config(file)
      options = {}
      if File.exists? file
        config_options = YAML.load_file file
        config_options = config_options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        options.merge! config_options
      end
      options
    end

    def normalize_name(name = nil)
      if name
        name.gsub(/\W/, '-').downcase
      else
        'fontcustom'
      end
    end
  end
end
