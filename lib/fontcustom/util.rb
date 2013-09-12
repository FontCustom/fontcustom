##
# Expects access to @shell and @opts
module Fontcustom
  module Util
    def check_fontforge
      fontforge = `which fontforge`
      if fontforge == "" || fontforge == "fontforge not found"
        raise Fontcustom::Error, "Please install fontforge. Visit http://fontcustom.com for instructions."
      end
    end

    def say_changed(status, changed)
      return unless opts(:verbose)
      message = changed.map { |file| relative_to_root(file) }
      @shell.say_status status, message.join(" ")
    end

    def say_message(status, message)
      return unless opts(:verbose)
      @shell.say_status status, message
    end

    def relative_to_root(path)
      path = path.sub(opts(:project_root), "")
      path = path[1..-1] if path[0] == "/"
      path
    end

    def overwrite_file(file, content = "")
      File.open(file, "w") { content }
      say_changed :updated, [ file ]
    end

    private

    def opts(sym)
      # Generators have @opts, while Options has @cli_options
      if @opts
        @opts.send sym
      else
        @cli_options[sym]
      end
    end
  end
end
