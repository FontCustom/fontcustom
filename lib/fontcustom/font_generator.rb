require 'json'
require 'fileutils'

module Fontcustom
  class FontGenerator
    def self.generate(input_dir, output_dir = File.join(File.dirname(input_dir), 'fontcustom'))
      verify_or_create_directories(input_dir, output_dir)

      file_path = File.expand_path(File.join(File.dirname(__FILE__)))
      output = %x| fontforge -script #{file_path}/scripts/generate.py #{input_dir} #{output_dir} 2>&1 /dev/null |

      parse_script_output(output)
    end

    def self.verify_or_create_directories(input_dir, output_dir)
      if ! File.directory?(input_dir)
        raise "#{input_dir} does not exist. Did you mistype it?"
      end

      if ! File.directory?(output_dir)
        FileUtils.mkdir_p output_dir
      end
    end

    def self.parse_script_output(output)
      output = JSON.parse(output.split("\n").last)
      output['files']
    end
  end
end
