require "digest/sha2"

module Fontcustom
  class Base
    include Fontcustom::Utility

    def initialize(cli_options)
      @options = Fontcustom::Options.new(cli_options)
      @manifest = @options[:manifest]
      Fontcustom::Generator::Manifest.new(@options)
    end

    def compile
      current_hash = checksum
      manifest = get_manifest
      if current_hash != manifest[:checksum]
        start_generators
        update_manifest :checksum, current_hash
      else
        # "no change" message
      end
    end

    private

    # Calculates a hash of vectors and templates
    def checksum
      files = Dir.glob File.join(@options[:input][:vectors], "*.svg")
      files += @options[:templates]
      content = files.map { |file| File.read(file) }.join
      Digest::SHA2.hexdigest(content).to_s
    end

    def start_generators
      # noop until Options, Utility, and Manifest are done
    end
  end
end
