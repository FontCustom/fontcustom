require "digest/sha2"

module Fontcustom
  class Base
    include Utility

    def initialize(raw_options)
      check_fontforge
      manifest = File.join Dir.pwd, ".fontcustom-manifest.json"
      raw_options[:manifest] = manifest
      @options = Fontcustom::Options.new(raw_options).options
      @manifest = Fontcustom::Manifest.new(manifest, @options)
    end

    def compile
      current = checksum
      previous = @manifest.get(:checksum)[:previous]
      if @options[:force] || current != previous
        @manifest.set :checksum, {:previous => previous, :current => current}
        start_generators
        @manifest.reload
        @manifest.set :checksum, {:previous => current, :current => current}
      else
        say_message :status, "No changes detected. Skipping compilation."
      end
    end

    private

    def check_fontforge
      fontforge = `which fontforge`
      if fontforge == "" || fontforge == "fontforge not found"
        raise Fontcustom::Error, "Please install fontforge first. Visit <http://fontcustom.com> for instructions."
      end
    end

    # Calculates a hash of vectors, options, and templates (content and filenames)
    def checksum
      files = Dir.glob File.join(@options[:input][:vectors], "*.svg")
      files += Dir.glob File.join(@options[:input][:templates], "*")
      content = files.map { |file| File.read(file) }.join
      content << files.join
      content << @options.flatten(2).join
      Digest::SHA2.hexdigest(content).to_s
    end

    def start_generators
      Fontcustom::Generator::Font.new(@options).generate
      Fontcustom::Generator::Template.new(@options).generate
    end
  end
end
