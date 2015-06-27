require 'json'
require 'thor/actions'
require 'thor/shell'
require 'thor/shell/basic'
require 'thor/shell/color'

# Requires access to:
#   @options or @cli_options
#   @manifest
module Fontcustom
  module Utility
    include Thor::Actions

    #
    # Hacks that allow Thor::Actions and Thor::Shell to be used in Fontcustom classes.
    #

    def self.shell
      @shell || Thor::Shell::Color.new
    end

    def shell
      Fontcustom::Utility.shell
    end

    def behavior
      :invoke
    end

    def say_status(*args)
      shell.say_status(*args)
    end

    def destination_root
      @destination_stack ||= [project_root]
      @destination_stack.last
    end

    def source_paths
      @source_paths ||= [File.join(Fontcustom.gem_lib, 'templates'), Dir.pwd]
    end

    #
    # Options
    #

    module HashWithMethodAccess
      def method_missing(method, arg = nil)
        if method[-1, 1] == '='
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

    def project_root
      if @manifest.is_a? String
        File.dirname @manifest
      else
        File.dirname @manifest.manifest
      end
    end

    #
    # File Manipulation
    #

    def write_file(file, content = '', message = nil, message_body = nil)
      File.open(file, 'w') { |f| f.write(content) }
      if message
        body = message_body || file
        say_message message, body
      end
    end

    #
    # Messages
    #

    def say_message(status, message, color = nil)
      return if options[:quiet] && status != :error && status != :debug
      color = :red if [:error, :debug, :warn].include?(status)
      say_status status, message, color
    end

    def say_changed(status, changed)
      return if options[:quiet] || !options[:debug] && status == :delete
      say_status status, changed.join(line_break)
    end

    # magic number for Thor say_status line breaks
    def line_break(n = 14)
      "\n#{' ' * n}"
    end

    def options
      if @data
        @data[:options]
      else
        @options || @cli_options || @config_options || {}
      end
    end
  end
end
