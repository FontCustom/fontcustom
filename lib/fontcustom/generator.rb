require 'json'
require 'thor/group'

module Fontcustom
  class Generator < Thor::Group
    include Thor::Actions

    desc 'Generates webfonts from given directory of vectors.'

    argument :input, :type => :string
    class_option :output, :aliases => '-o'
    class_option :name, :aliases => '-n'
    class_option :nohash, :type => :boolean, :default => false

    def self.source_root
      File.dirname(__FILE__)
    end

    def verify_fontforge
      if `which fontforge` == ''
        raise Thor::Error, 'Please install fontforge first.'
      end
    end

    def verify_input_dir
      if ! File.directory?(input)
        raise Thor::Error, "#{input} doesn't exist or isn't a directory."
      elsif Dir[File.join(input, '*.{svg,eps}')].empty?
        raise Thor::Error, "#{input} doesn't contain any vectors (*.svg or *.eps files)."
      end
    end

    def verify_or_create_output_dir
      @output = options.output.nil? ? File.join(File.dirname(input), 'fontcustom') : options.output
      empty_directory(@output) unless File.directory?(@output)
    end

    def cleanup_output_dir
      originals = Dir[File.join(@output, 'fontcustom*.{css,woff,ttf,eot,svg}')]
      originals.each {|file| remove_file file }
    end

    def generate
      gem_file_path = File.expand_path(File.join(File.dirname(__FILE__)))
      name = options.name ? ' --name ' + options.name : ''
      nohash = options.nohash ? ' --nohash' : ''

      # suppress fontforge message
      # TODO get font name and classes from script (without showing fontforge message)
      `fontforge -script #{gem_file_path}/scripts/generate.py #{input} #{@output + name + nohash} > /dev/null 2>&1`
    end

    def show_paths
      name = options.name || 'fontcustom'
      file = Dir[File.join(@output, name + '*.ttf')].first
      @font_path = file.chomp('.ttf')

      ['woff','ttf','eot','svg'].each do |type|
        say_status(:create, @font_path + '.' + type)
      end
    end

    def create_stylesheet
      files = Dir[File.join(input, '*.{svg,eps}')]
      @classes = files.map {|file| File.basename(file)[0..-5].gsub(/\W/, '-').downcase }
      @font = File.basename(@font_path)

      template('templates/fontcustom.css', File.join(@output, 'fontcustom.css'))
    end
  end
end
