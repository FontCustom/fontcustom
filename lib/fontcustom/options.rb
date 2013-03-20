require 'yaml'

class Fontcustom
  class Options
    class << self
      def parse_options(args = {})
        options = {
          :font_name => 'fontcustom',
          :font_path => './',
          :input_dir => `pwd`.chomp,
          :output_dir => File.join(`pwd`.chomp, 'fontcustom'),
          :css_template => Fontcustom::Util.template('css'),
          :css_prefix => '.icon-',
          :hash => true,
          :html => false,
          :debug => false
        }
        
        input_dir = args[:input_dir] || options[:input_dir]
        config_file = args[:config_file] || File.join(input_dir, 'fontcustom.yml')

        if File.exists? config_file
          config_options = YAML.load_file config_file
          config_options = config_options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
          options.merge! config_options
        end

        unless args.empty?
          options.merge! args
        end

        options
      end
    end
  end
end
