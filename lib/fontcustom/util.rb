##
# Needs access to @shell and an Options instance
# (@opts in thor, @cli_options or self in Options)
module Fontcustom
  module Util
    def overwrite_file(file, content = "")
      File.open(file, "w") { |f| f.write(content) }
      # say_changed :update, [ file ]
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
