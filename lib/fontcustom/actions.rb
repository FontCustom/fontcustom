require "thor/actions"
require "thor/shell"
require "thor/shell/basic"
require "thor/shell/color"

module Fontcustom
  module Actions
    def self.included(base)
      base.send :include, Thor::Actions
    end

    # TODO Currently not sure how Thor classes inherit `say_status` from Thor::Shell.
    # Using the instance variable as a workaround.
    def say_changed(status, changed)
      return unless opts[:verbose]
      message = changed.map do |file| 
        file.gsub!(opts[:project_root], "")
        file = file[1..-1] if file[0] == "/"
        file
      end
      @shell.say_status status, message.join(" ") 
    end

    def clear_file(file)
      File.open(file, "w") {}
    end
  end
end
