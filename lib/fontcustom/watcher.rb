require "fontcustom"
require "listen"

module Fontcustom
  class Watcher
    include Fontcustom::Util

    def initialize(opts)
      @opts = opts
      @vector_listener = Listen.to(@opts.input[:vectors]).relative_paths(true).filter(/\.(eps|svg)$/).change(&callback)

      templates = @opts.templates.dup
      templates.delete_if do |template|
        template.match Fontcustom.gem_lib
      end
      unless templates.empty?
        templates = templates.map do |template|
          File.basename template
        end
        @template_listener = Listen.to(@opts.input[:templates]).relative_paths(true).filter(/(#{templates.join("|")})/).change(&callback)
      end

      # Modified to allow testing
      @is_test = @opts.instance_variable_get :@is_test
      if @is_test
        @vector_listener = @vector_listener.polling_fallback_message(false)
        @template_listener = @template_listener.polling_fallback_message(false) if @template_listener
      end
    end

    def watch
      puts "Font Custom is watching your icons at `#{relative_to_root(@opts.input[:vectors])}`. Press Ctrl + C to stop."
      compile unless @opts.skip_first
      start
    rescue SignalException # Catches Ctrl + C
      stop
    end

    private

    def start
      if @is_test # Non-blocking listener
        @vector_listener.start
        @template_listener.start if @template_listener
      else
        @vector_listener.start!
        @template_listener.start! if @template_listener
      end
    end

    def stop
      @vector_listener.stop
      @template_listener.stop if @template_listener
      puts "\nFont Custom is signing off. Good night and good luck."
    end

    def callback
      Proc.new do |modified, added, removed|
        begin
          puts "  >> Changed: " + modified.join(", ") unless modified.empty?
          puts "  >> Added: " + added.join(", ") unless added.empty?
          puts "  >> Removed: " + removed.join(", ") unless removed.empty?
          changed = modified + added + removed
          compile unless changed.empty?
        rescue Fontcustom::Error => e
          @opts.say_message :error, e.message
        end
      end
    end

    def compile
      Fontcustom::Generator::Font.start [@opts]
      Fontcustom::Generator::Template.start [@opts]
    end
  end
end
