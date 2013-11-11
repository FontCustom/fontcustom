module Fontcustom
  class Manifest
    include Utility

    attr_reader :manifest

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
      @manifest = get_manifest
      if @manifest[:options] != @options
        @manifest[:options] = @options
        save_manifest
      end
    end

    def create_manifest
      @manifest = {
        :checksum => "",
        :fonts => [],
        :glyphs => {},
        :options => @options,
        :templates => []
      }
      json = JSON.pretty_generate @manifest
      write_file @options[:manifest], json, :create
    end
  end
end
