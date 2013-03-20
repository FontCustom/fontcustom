require 'thor'

class Fontcustom
  class Util < Thor
    class << self
      def root
        File.dirname __FILE__
      end

      def template(name)
        File.join root, 'templates', name
      end

      def verify_all
        verify_fontforge(`which fontforge`)
        verify_input_dir
        verify_dir_dir
      end

      def verify_fontforge(which) # arg to allow unit testing
        if which == ''
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
    end
  end
end
