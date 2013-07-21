require "fontcustom"
require "listen"

module Fontcustom
  class Watcher
    def initialize(opts)
      @opts = opts
      @listener = Listen.to(@opts[:input]).relative_paths(true).filter(/\.(eps|svg)$/).change(&callback)
      @opts[:blocking] = @opts[:blocking] == false ? false : true
      @listener = @listener.polling_fallback_message(false) unless @opts[:blocking]
    end

    def watch
      puts "Font Custom is watching your icons at #{@opts[:input]}. Press Ctrl + C to stop."
      compile unless @opts[:skip_first]

      if @opts[:blocking]
        @listener.start!
      else
        @listener.start
      end

    rescue Fontcustom::Error => e
      show_error e

    # Catches Ctrl + C
    # TODO Does the listen gem have a better way of handling this?
    rescue SignalException
      stop
    end

    def stop
      # Adding a newline so message is not prepended with ^C on SIGTERM
      puts "\nFont Custom is signing off. Good night and good luck."
      @listener.stop
    end

    private

    def callback
      Proc.new do |modified, added, removed|
        begin
          puts "  >> Changed: " + modified.join(", ") unless modified.empty?
          puts "  >> Added: " + added.join(", ") unless added.empty?
          puts "  >> Removed: " + removed.join(", ") unless removed.empty?

          changed = modified + added + removed
          compile unless changed.empty?
        rescue Fontcustom::Error => e
          show_error e
        end
      end
    end

    def compile
      Fontcustom::Generator::Font.start [@opts]
      Fontcustom::Generator::Template.start [@opts]
    end

    def show_error(err)
      puts "ERROR: #{err.message}"
    end
  end
end
