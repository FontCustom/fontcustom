require 'listen'

module Fontcustom
  class Watcher
    def self.watch(*args)
      dir = args.first
      puts 'Fontcustom is watching your icons at ' + dir

      @listener = Listen.to(dir, :filter => /\.(svg|eps)$/) do |modified, added, removed|
        puts '    >> Changed: ' + modified.join(' ') unless modified.empty?
        puts '    >> Added: ' + added.join(' ') unless added.empty?
        puts '    >> Removed: ' + removed.join(' ') unless removed.empty?

        changed = modified + added + removed
        Fontcustom.compile(*args) unless changed.empty?
      end
    end

    def self.stop
      puts 'Fontcustom is signing off. Goodnight and good luck.'
      @listener.stop
    end
  end
end
