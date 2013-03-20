class Fontcustom
  class Util
    class << self
      def root
        File.expand_path '..', __FILE__
      end

      def template(name)
        File.join root, 'templates', name
      end

      def verify_all
        verify_fontforge
        verify_input_dir
        verify_dir_dir
      end

      def verify_fontforge
        if `which fontforge` == ''
          raise Thor::Error, 'Please install fontforge first.'
        end
      end

      def verify_input_dir(input)
        if ! File.directory? input 
          raise Thor::Error, "#{input} doesn't exist or isn't a directory."
        elsif Dir[File.join(input, '*.{svg,eps}')].empty?
          raise Thor::Error, "#{input} doesn't contain any vectors (*.svg or *.eps files)."
        end
      end

      def verify_or_create_output_dir
        @output = options.output.nil? ? File.join(File.dirname(input), 'fontcustom') : options.output
        empty_directory(@output) unless File.directory?(@output)
      end

    end
  end
end
