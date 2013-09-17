##
# Needs access to @shell and an Options instance
# (@opts in thor, @cli_options or self in Options)
module Fontcustom
  module Util
    def check_fontforge
      fontforge = `which fontforge`
      if fontforge == "" || fontforge == "fontforge not found"
        raise Fontcustom::Error, "Please install fontforge. Visit <http://fontcustom.com> for instructions."
      end
    end

    def say_changed(status, changed)
      return if base(:quiet)
      message = changed.map { |file| relative_to_root(file) }
      @shell.say_status status, message.join("\n#{" " * 14}"), :green # magic number
    end

    def say_message(status, message, color = :yellow)
      return if base(:quiet) && status != :error
      @shell.say_status status, message, color
    end

    def expand_path(path)
      return path if path[0] == "/"
      File.expand_path File.join(base(:project_root), path)
    end

    def relative_to_root(path)
      path = path.sub(base(:project_root), "")
      path = path[1..-1] if path[0] == "/"
      path = "." if path.empty?
      path
    end

    def overwrite_file(file, content = "")
      File.open(file, "w") { |f| f.write(content) }
      # say_changed :update, [ file ]
    end

    def symbolize_hash(hash)
      hash.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
    end

    private

    def base(sym)
      # Generators have @opts
      if @opts
        @opts.send sym

      # Options (before merge) uses @cli_options
      elsif @cli_options
        @cli_options[sym]

      # Options (after merge) has its own methods
      else
        send sym
      end
    end
  end
end
