require 'thor'

class Thor::Shell::Basic
  # Always overwrite old file
  def file_collision(destination)
    true
  end
end
