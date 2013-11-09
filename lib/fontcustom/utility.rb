require "json"
require "thor/actions"

# Requires access to @options or @cli_options
module Fontcustom
  module Utility
    include Thor::Actions

    #
    # Options
    #

    module HashWithMethodAccess
      def method_missing(method, arg = nil)
        if method[-1, 1] == "="
          self[method[0...-1].to_sym] = arg
        else
          self[method.to_sym]
        end
      end
    end

    def symbolize_hash(hash)
      hash.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
    end

    def methodize_hash(hash)
      hash.extend HashWithMethodAccess
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
    # Manifest / Files
    #

    def write_file(file, content = "", message = nil, message_body = nil)
      File.open(file, "w") { |f| f.write(content) }
      if message
        body = message_body || relative_to_root(file)
        say_message message, body
      end
    end

    def garbage_collect(files)
    end

    def get_manifest(file = _options[:manifest])
      begin
        manifest = File.read file
        JSON.parse(manifest, :symbolize_names => true)
      rescue JSON::ParserError
        raise Fontcustom::Error, "Couldn't parse `#{relative_to_root file}`. Did you modify the file?"
      end
    end

    def set_manifest(key, val)
      @manifest ||= get_manifest
      if key == :all
        @manifest = val
      else
        @manifest[key] = val
      end
      json = JSON.pretty_generate @manifest
      write_file _options[:manifest], json, :update
    end

    #
    # Messages
    # TODO
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

    private

    def _options
      @options || @cli_options
    end
  end
end
