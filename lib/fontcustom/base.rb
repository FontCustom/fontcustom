require "digest/sha2"

module Fontcustom
  class Base
    include Utility

    def initialize(cli_options)
      @cli_options = cli_options
      check_fontforge
      init_manifest
    end

    def compile
      @manifest[:checksum][:current] = checksum
      if @options[:force] || @manifest[:checksum][:current] != @manifest[:checksum][:previous]
        save_manifest
        start_generators
        @manifest = get_manifest
        @manifest[:checksum][:previous] = @manifest[:checksum][:current]
        save_manifest
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

    def init_manifest
      file = @cli_options[:manifest] || File.join(Dir.pwd, ".fontcustom-manifest.json")
      @options = Fontcustom::Options.new(@cli_options).options
      @manifest = Fontcustom::Manifest.new(@options).manifest
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
      Fontcustom::Generator::Font.new(@options[:manifest]).generate
      Fontcustom::Generator::Template.new(@options[:manifest]).generate
    end
  end
end
