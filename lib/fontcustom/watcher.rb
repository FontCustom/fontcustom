require 'listen'

module Fontcustom
  class Watcher
    def self.watch(*args)
      callback = Proc.new do |modified, added, removed|
        puts '    >> Changed: ' + modified.join(' ') unless modified.empty?
        puts '    >> Added: ' + added.join(' ') unless added.empty?
        puts '    >> Removed: ' + removed.join(' ') unless removed.empty?

        changed = modified + added + removed
        Fontcustom.compile(*args) unless changed.empty?
      end

      dir = args.first
      @listener = Listen.to(dir).filter(/\.(eps|svg)$/).change(&callback)

      begin
        puts 'Fontcustom is watching your icons at ' + dir
        puts 'Press Ctrl + C to stop.'
        Fontcustom.compile(*args)
        @listener.start()

      # Catches Ctrl + C
      # Does listen gem have a better way of handling this?
      rescue SignalException
        stop
      end
    end

    def self.stop
      # Newline exists so message is not prepended with ^C on SIGTERM
      puts "\nFontcustom is signing off. Goodnight and good luck."
      @listener.stop
    end
  end
end
