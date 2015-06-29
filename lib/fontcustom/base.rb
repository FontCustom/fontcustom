require 'digest/sha2'

module Fontcustom
  class Base
    include Utility

    def initialize(raw_options)
      check_fontforge
      manifest = '.fontcustom-manifest.json'
      raw_options[:manifest] = manifest
      @options = Fontcustom::Options.new(raw_options).options
      @manifest = Fontcustom::Manifest.new(manifest, @options)
    end

    def compile
      current = checksum
      previous = @manifest.get(:checksum)[:previous]

      say_message :status, 'Forcing compile.' if @options[:force]
      if @options[:force] || current != previous
        @manifest.set :checksum, previous: previous, current: current
        start_generators
        @manifest.reload
        @manifest.set :checksum, previous: current, current: current
      else
        say_message :status, 'No changes detected. Skipping compile.'
      end
    end

    private

    def check_fontforge
      fontforge = `which fontforge`
      if fontforge == '' || fontforge == 'fontforge not found'
        fail Fontcustom::Error, 'Please install fontforge first. Visit <http://fontcustom.com> for instructions.'
      end
    end

    # Calculates a hash of vectors, options, and templates (content and filenames)
    def checksum
      files = Dir.glob(File.join(@options[:input][:vectors], '*.svg')).select { |fn| File.file?(fn) }
      files += Dir.glob(File.join(@options[:input][:templates], '*')).select { |fn| File.file?(fn) }
      content = files.map { |file| File.read(file) }.join
      content << files.join
      content << @options.flatten(2).join
      Digest::SHA2.hexdigest(content).to_s
    end

    def start_generators
      Fontcustom::Generator::Font.new(@manifest.manifest).generate
      Fontcustom::Generator::Template.new(@manifest.manifest).generate
    end
  end
end
