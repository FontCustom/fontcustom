require "fontcustom"
require "listen"

module Fontcustom
  class Watcher
    def initialize(options)
      @options = options
      @listener = Listen.to(@options[:input]).relative_paths(true).filter(/\.(eps|svg)$/).change(&callback)
      @options[:blocking] = @options[:blocking] == false ? false : true
      @listener = @listener.polling_fallback_message(false) unless @options[:blocking]
    end

    def watch
      begin
        puts "Fontcustom is watching your icons at #{@options[:input]}. Press Ctrl + C to stop."
        compile
        @listener.start @options[:blocking]

      # Catches Ctrl + C
      # TODO Does the listen gem have a better way of handling this?
      rescue SignalException
        stop
      end
    end

    def stop
      # Newline exists so message is not prepended with ^C on SIGTERM
      puts "\nFontcustom is signing off. Good night and good luck."
      @listener.stop
    end

    private

    def callback
      Proc.new do |modified, added, removed|
        puts "  >> Changed: " + modified.join(", ") unless modified.empty?
        puts "  >> Added: " + added.join(", ") unless added.empty?
        puts "  >> Removed: " + removed.join(", ") unless removed.empty?

        changed = modified + added + removed
        compile unless changed.empty?
      end
    end

    def compile
      Fontcustom::Generator::Font.start [@options]
      Fontcustom::Generator::Template.start [@options]
    end
  end
end
