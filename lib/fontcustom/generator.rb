require 'json'
require 'thor/group'

module Fontcustom
  class Generator < Thor::Group
    include Thor::Actions

    desc 'Generates webfonts from given directory of vectors.'

    argument :input, :type => :string
    class_option :output, :aliases => '-o'
    class_option :name, :aliases => '-n'
    class_option :font_path, :aliases => '-f'
    class_option :nohash, :type => :boolean, :default => false
    class_option :debug, :type => :boolean, :default => false
    class_option :html, :type => :boolean, :default => false
    class_option :json, :type => :boolean, :default => false

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

    def normalize_name
      @name = if options.name
        options.name.gsub(/\W/, '-').downcase
      else
        'fontcustom'
      end
    end

    def cleanup_output_dir
      css = File.join(@output, 'fontcustom.css')
      css_ie7   = File.join(@output, 'fontcustom-ie7.css')
      test_html = File.join(@output, 'test.html')
      json_data = File.join(@output, 'fontcustom.json')
      old_name = if File.exists? css
                   line = IO.readlines(css)[5]                           # font-family: "Example Font";
                   line.scan(/".+"/)[0][1..-2].gsub(/\W/, '-').downcase  # => 'example-font'
                 else
                   'fontcustom'
                 end

      old_files = Dir[File.join(@output, old_name + '-*.{woff,ttf,eot,svg}')]
      old_files << css if File.exists?(css)
      old_files << css_ie7 if File.exists?(css_ie7)
      old_files << test_html if File.exists?(test_html)
      old_files << json_data if File.exists?(json_data)
      old_files.each {|file| remove_file file }
    end

    def generate
      gem_file_path = File.expand_path(File.join(File.dirname(__FILE__)))
      name = options.name ? ' --name ' + @name : ''
      nohash = options.nohash ? ' --nohash' : ''

      # suppress fontforge message
      # TODO get font name and classes from script (without showing fontforge message)
      cmd = "fontforge -script #{gem_file_path}/scripts/generate.py #{input} #{@output + name + nohash}"
      unless options.debug
        cmd += " > /dev/null 2>&1"
      end
      `#{cmd}`
    end

    def show_paths
      file = Dir[File.join(@output, @name + '*.ttf')].first
      @path = file.chomp('.ttf')

      ['woff','ttf','eot','svg'].each do |type|
        say_status(:create, @path + '.' + type)
      end
    end

    def create_stylesheet
      files = Dir[File.join(input, '*.{svg,eps}')]
      @classes = files.map {|file| File.basename(file)[0..-5].gsub(/\W/, '-').downcase }
      if(!options.font_path.nil?)
        font_path = (options.font_path) ? options.font_path : ''
        @path = File.join(font_path, File.basename(@path))
      else
        @path = File.basename(@path)
      end

      template('templates/fontcustom.css', File.join(@output, 'fontcustom.css'))
      template('templates/fontcustom-ie7.css', File.join(@output, 'fontcustom-ie7.css'))
      template('templates/test.html', File.join(@output, 'test.html')) if options.html

      if options.json
        # Create a new hash to hold all font data. JSON-encoding the hash ensures
        # we handle all possible glyph names appropriately
        font_data = {:name => @name, :path => @path, :glyphs => Hash.new}
        @classes.each_with_index do |glyph, position|
          font_data[:glyphs][glyph] = (61696 + position)
        end
        @json = JSON.pretty_generate(font_data)
        template('templates/fontcustom.json', File.join(@output, 'fontcustom.json'))
      end
    end
  end
end
