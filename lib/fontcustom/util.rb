module Fontcustom
  class Util
    class << self 
      def check_fontforge
        if `which fontforge` == ""
          raise Thor::Error, "Please install fontforge first. Visit http://fontcustom.com for more details."
        end
      end

      def parse_options(options)
        options
      end

      def lower_spinal_case(string)
        string.gsub(/\W/, '-').downcase
      end
    end
  end
end
