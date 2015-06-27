module Fontcustom
  class Manifest
    include Utility

    attr_reader :manifest

    def initialize(manifest, cli_options = {})
      @manifest = manifest
      @cli_options = symbolize_hash cli_options
      if File.exist? @manifest
        reload
        if ! @cli_options.empty? && get(:options) != @cli_options
          set :options, @cli_options
        end
      else
        create_manifest @cli_options
      end
    end

    # TODO convert paths to absolute
    def get(key)
      @data[key]
    end

    # TODO convert paths to relative
    def set(key, value, status = nil)
      if key == :all
        @data = value
      else
        @data[key] = value
      end
      json = JSON.pretty_generate @data
      write_file @manifest, json, status
    end

    def reload
      json = File.read @manifest
      @data = JSON.parse json, symbolize_names: true
    rescue JSON::ParserError
      raise Fontcustom::Error,
            "Couldn't parse `#{@manifest}`. Fix any invalid "\
            'JSON or delete the file to start from scratch.'
    end

    def delete(key)
      files = get(key)
      return if files.empty?
      begin
        deleted = []
        files.each do |file|
          remove_file file, verbose: false
          deleted << file
        end
      ensure
        set key, files - deleted
        say_changed :delete, deleted
      end
    end

    private

    def create_manifest(options)
      defaults = {
        checksum: { current: '', previous: '' },
        fonts: [],
        glyphs: {},
        options: options,
        templates: []
      }
      set :all, defaults, :create
    end
  end
end
