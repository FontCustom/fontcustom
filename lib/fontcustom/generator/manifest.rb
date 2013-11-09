module Fontcustom
  module Generator
    class Manifest
      include Utility

      def initialize(options)
        @options = options
        update_or_create_manifest
      end

      def update_or_create_manifest
        if File.exists? @options[:manifest]
          update_manifest
        else
          create_manifest
        end
      end

      private

      def update_manifest
        manifest = get_manifest
        set_manifest :options, @options if manifest[:options] != @options
      end

      def create_manifest
        json = JSON.pretty_generate(
          :checksum => "",
          :fonts => [],
          :glyphs => {},
          :options => @options,
          :templates => []
        )
        write_file @options[:manifest], json, :create
      end
    end
  end
end
