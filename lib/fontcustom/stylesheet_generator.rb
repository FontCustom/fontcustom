require 'thor/group'

module Fontcustom
  class StylesheetGenerator < Thor::Group
    include Thor::Actions

    desc 'Generates a stylesheet with @font-face includes and ".icon-#{name}" classes.'

    argument :icon_names, :type => :array
    argument :font_name, :type => :string
    argument :output_dir, :type => :string

    def self.source_root
      File.dirname(__FILE__)
    end

    def create_directory
      empty_directory output_dir
    end

    def create_stylesheet
      template('templates/fontcustom.css', output_dir + '/fontcustom.css')
    end
  end
end
