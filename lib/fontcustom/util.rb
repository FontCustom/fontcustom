require "thor/shell"
require "thor/shell/basic"
require "thor/shell/color"

##
# Expects @shell and @opts to be accessible
module Fontcustom
  module Util
    def check_fontforge
      fontforge = `which fontforge`
      if fontforge == "" || fontforge == "fontforge not found"
        raise Fontcustom::Error, "Please install fontforge. Visit http://fontcustom.com for instructions."
      end
    end

    # TODO Currently not sure how Thor classes inherit `say_status` from Thor::Shell.
    # Using @shell (automatically set in Thor classes) as a workaround.
    def say_changed(status, changed)
      return unless opts[:verbose]
      message = changed.map { |file| relative_to_root(file) }
      @shell.say_status status, message.join(" ")
    end

    def relative_to_root(path)
      path.sub!(opts[:project_root], "")
      path = path[1..-1] if path[0] == "/"
      path
    end

    def overwrite_file(file, content = "")
      File.open(file, "w") { content }
      say_changed :updated, [ file ]
    end
  end
end
