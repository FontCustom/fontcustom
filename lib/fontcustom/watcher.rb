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
      @listener = Listen.to(dir).change(&callback)
      @listener.start(false)
      puts 'Fontcustom is watching your icons at ' + dir
    end

    def self.stop
      puts 'Fontcustom is signing off. Goodnight and good luck.'
      @listener.stop
    end
  end
end
