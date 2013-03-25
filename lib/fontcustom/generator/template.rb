module Fontcustom
  module Generator
    class Template
      def initialize(base)
        @base = base
        @opts = base.opts
      end

      def start
        if @opts.templates.empty?
          @base.error "No templates specified."
        else
          generate(template_paths)
        end
      end

      private

      def template_paths
        @opts.templates.map do |template|
          if template.is_a? Symbol
            case template # TODO flesh out other scenarios
            when :scss
              "_fontcustom.#{template.to_s}"
            else
              "fontcustom.#{template.to_s}"
            end
          elsif template.is_a?(String) && File.exists?(template)
            template            
          else 
            @base.error "Could not find template: " + template
          end
        end
      end

      def generate(templates)
        files = []
        templates.each do |template|
          name = template.sub('fontcustom', @opts.font_name)
          files << name
          output = File.join @opts.output_dir, name
          @base.copy_template template, output
        end
        @base.update_data_file(@opts.output_dir, files)
      end
    end
  end
end
