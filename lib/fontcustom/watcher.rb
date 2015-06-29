require 'fontcustom'
require 'listen'

module Fontcustom
  class Watcher
    include Utility

    def initialize(options, is_test = false)
      @base = Fontcustom::Base.new options
      @options = @base.options
      @is_test = is_test

      templates = @options[:templates].dup.map { |template| File.basename(template) }
      packaged = %w(preview css scss scss-rails)
      templates.delete_if { |template| packaged.include?(template) }

      create_listener(templates)
    end

    def watch
      compile unless @options[:skip_first]
      start
    rescue SignalException # Catches Ctrl + C
      stop
    end

    private

    def create_listener(templates)
      listen_options = {}
      listen_options[:polling_fallback_message] = false if @is_test

      listen_dirs = [@options[:input][:vectors]]
      listen_dirs << @options[:input][:templates] unless templates.empty?

      if listen_eq2
        listen_options[:only] = /(#{templates.join("|")}|.+\.svg)$/
        @listener = Listen.to(listen_dirs, listen_options, &callback)
      else
        listen_options[:filter] = /(#{templates.join("|")}|.+\.svg)$/
        listen_options[:relative_paths] = true
        @listener = Listen::Listener.new(listen_dirs, listen_options, &callback)
      end
    end

    def start
      if @is_test # Non-blocking listener
        @listener.start
      else
        if listen_eq2
          @listener.start
          sleep
        else
          @listener.start!
        end
      end
    end

    def stop
      @listener.stop
      shell.say "\nFont Custom is signing off. Good night and good luck.", :yellow
    end

    def callback
      proc do |modified, added, removed|
        begin
          say_message :changed, modified.join(', ') unless modified.empty?
          say_message :added, added.join(', ') unless added.empty?
          say_message :removed, removed.join(', ') unless removed.empty?
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

    def listen_eq2
      require 'listen/version'
      ::Listen::VERSION =~ /^2\./
    rescue LoadError
      false
    end
  end
end
