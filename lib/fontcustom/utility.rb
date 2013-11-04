require "json"

# Requires access to @options or @cli_options
module Fontcustom
  module Utility

    # 
    # Options
    #
    def symbolize_hash(hash)
      hash.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
    end

    #
    # Paths
    #

    def expand_path(path)
      return path if path[0] == "/" # ignore absolute paths
      File.expand_path File.join(_options[:project_root], path)
    end

    def relative_to_root(path)
      path = path.sub(_options[:project_root], "")
      path = path[1..-1] if path[0] == "/"
      path = "." if path.empty?
      path
    end

    #
    # Messages
    #
    
    def say_message(status, message, color = :yellow)
      #return if _options(:quiet) && status != :error
      #@shell.say_status status, message, color
    end

    def say_changed(status, changed)
      #return if _options(:quiet)
      #message = changed.map { |file| relative_to_root(file) }
      #@shell.say_status status, message.join("\n#{" " * 14}"), :green # magic number
    end

    #
    # Manifest
    #

    def get_manifest
      manifest = File.read _options[:manifest]
      if ! manifest.empty?
        JSON.parse(manifest, :symbolize_names => true)
      else
        # Empty manifest error
      end
    end

    def set_manifest(key, val)
    end

    private

    def _options
      @options || @cli_options
    end
  end
end
