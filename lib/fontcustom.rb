require 'fontcustom/version'
require 'fontcustom/core'

module Fontcustom
  ##
  # For calling convenience
  def self.method_missing(*args)
    Fontcustom::Core.send *args
  end
end
