##
# Needs access to @shell and an Options instance 
# (@opts in thor, @cli_options or self in Options)
module Fontcustom
  module Util
    def check_fontforge
      fontforge = `which fontforge`
      if fontforge == "" || fontforge == "fontforge not found"
        raise Fontcustom::Error, "Please install fontforge. Visit http://fontcustom.com for instructions."
      end
    end

    def say_changed(status, changed)
      return unless base(:verbose)
      message = changed.map { |file| relative_to_root(file) }
      @shell.say_status status, message.join(" ")
    end

    def say_message(status, message)
      return unless base(:verbose)
      @shell.say_status status, message
    end

    def relative_to_root(path)
      path = path.sub(base(:project_root), "")
      path = path[1..-1] if path[0] == "/"
      path
    end

    def overwrite_file(file, content = "")
      File.open(file, "w") { content }
      say_changed :updated, [ file ]
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
