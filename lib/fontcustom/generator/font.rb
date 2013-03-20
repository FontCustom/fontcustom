require 'json'

class Fontcustom::Generator
  class Font
    def initialize(options)
      @options = options
    end

    def generate
      # TODO normalize naming conventions with python script
      # TODO remove name arg if default is already set in python (or rm from python)
      name = @options.font_name ? ' --name ' + @options.font_name : ''
      hash = @options.hash ? '' : ' --nohash'
      cmd = "fontforge -script #{Fontcustom::Util.root}/scripts/generate.py #{@options.input_dir} #{@options.output_dir + name + hash}"
      run_script(cmd)
    end

    private

    def run_script(cmd)
      `#{cmd}`
    end
    
    def cleanup_old_files
    end
  end
end
