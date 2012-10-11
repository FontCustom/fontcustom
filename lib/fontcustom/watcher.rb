require 'listen'

module Fontcustom
  class Watcher
    def self.watch(dir, *args)
      @options = *args
      callback = Proc.new do |modified, added, removed|
        #puts 'm: ' + modified.inspect
        #puts 'a: ' + added.inspect
        #puts 'r: ' + removed.inspect
      end

      @listener = Listen.to(dir).change(&callback)
      @listener.start(false)
    end

    def self.stop
      @listener.stop
    end
  end
end
