class Fontcustom
  module Generator
    class Template
      def initialize(options)
        @options = options
      end

      def start
        if @options.templates.empty?
          Fontcustom.error "No templates specified."
        else
          generate(template_paths)
        end
      end

      private

      def template_paths
        @options.templates.map do |template|
          if template.is_a? Symbol
            case template # TODO flesh out other scenarios
            when :scss
              Fontcustom.template_path "_fontcustom.#{template.to_s}"
            else
              Fontcustom.template_path "fontcustom.#{template.to_s}"
            end
          elsif template.is_a?(String) && File.exists?(template)
            template            
          else 
            Fontcustom.error "Could not find template: " + template
          end
        end
      end

      def generate(templates)
        files = []
        templates.each do |template|
          name = @options.font_name + File.extname(template)
          files << name
          output = File.join @options.output_dir, name
          Fontcustom.copy_template template, output
        end
        Fontcustom.update_data_file(@options.output_dir, files)
      end
    end
  end
end
