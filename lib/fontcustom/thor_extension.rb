require 'thor'

# This is probably a bad idea.
# TODO Find a better way to force file overwriting. Remove the old one first in a preceeding task?
#
# @note Always overwrite old file in the event of a collision.
class Thor::Shell::Basic
  def file_collision(destination)
    true
  end
end
