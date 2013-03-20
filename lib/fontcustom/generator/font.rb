require 'thor/shell'

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

      cleanup_old_files
      run_script(cmd)
      show_paths
    end

    private

    def cleanup_old_files
      # TODO
    end

    def run_script(cmd)
      `#{cmd}`
    end
    
    def show_paths
      # TODO
      path = 'test'
      shell = ::Thor::Shell::Color.new
      ['woff','ttf','eot','svg'].each do |type|
        shell.say_status(:create, path + '.' + type)
      end
    end
  end
end
