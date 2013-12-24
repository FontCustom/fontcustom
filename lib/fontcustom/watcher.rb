require "fontcustom"
require "listen"

module Fontcustom
  class Watcher
    include Utility

    def initialize(options, is_test = false)
      @base = Fontcustom::Base.new options
      @options = @base.options
      @is_test = is_test

      templates = @options[:templates].dup.map { |template| File.basename(template) }
      packaged = %w|preview css scss scss-rails|
      templates.delete_if { |template| packaged.include?(template) }

      if templates.empty?
        @listener = Listen.to(@options[:input][:vectors])
      else
        @listener = Listen.to(@options[:input][:vectors], @options[:input][:templates])
      end

      @listener = @listener.relative_paths(true)
      @listener = @listener.filter(/(#{templates.join("|")}|.+\.svg)$/)
      @listener = @listener.change(&callback)
      @listener = @listener.polling_fallback_message(false) if @is_test
    end

    def watch
      compile unless @options[:skip_first]
      start
    rescue SignalException # Catches Ctrl + C
      stop
    end

    private

    def start
      if @is_test # Non-blocking listener
        @listener.start
      else
        @listener.start!
      end
    end

    def stop
      @listener.stop
      shell.say "\nFont Custom is signing off. Good night and good luck.", :yellow
    end

    def callback
      Proc.new do |modified, added, removed|
        begin
          say_message :changed, modified.join(", ") unless modified.empty?
          say_message :added, added.join(", ") unless added.empty?
          say_message :removed, removed.join(", ") unless removed.empty?
          changed = modified + added + removed
          compile unless changed.empty?
        rescue Fontcustom::Error => e
          say_message :error, e.message
        end
      end
    end

    def compile
      @base.compile
    end
  end
end
