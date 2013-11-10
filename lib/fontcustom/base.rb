require "digest/sha2"

module Fontcustom
  class Base
    include Utility

    def initialize(cli_options)
      check_fontforge
      init_manifest(cli_options)
    end

    def compile
      current_hash = checksum
      if current_hash != @manifest[:checksum]
        # FIXME ensure that old checksum is preserved in case compilation fails
        set_manifest :checksum, current_hash
        start_generators
      else
        # "no change" message
      end
    end

    private

    def check_fontforge
      fontforge = `which fontforge`
      if fontforge == "" || fontforge == "fontforge not found"
        raise Fontcustom::Error, "Please install fontforge. Visit <http://fontcustom.com> for instructions."
      end
    end

    def init_manifest(cli_options)
      file = cli_options[:manifest] || File.join(Dir.pwd, ".fontcustom-manifest.json")
      manifest_options = File.exists?(file) ? get_manifest(file)[:options] : {}
      @options = Fontcustom::Options.new(cli_options, manifest_options).options
      @manifest = Fontcustom::Manifest.new(@options).manifest
    end

    # Calculates a hash of vectors and templates
    def checksum
      files = Dir.glob File.join(@options[:input][:vectors], "*.svg")
      files += @options[:templates]
      content = files.map { |file| File.read(file) }.join
      Digest::SHA2.hexdigest(content).to_s
    end

    def start_generators
      Fontcustom::Generator::Font.new(@options[:manifest]).generate
      Fontcustom::Generator::Template.new(@options[:manifest]).generate
    end
  end
end
