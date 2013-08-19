# Refactor: Options / Actions / Util

## End goal:

```ruby
# in cli.rb
def compile(input)
  opts = options.merge input: input
  opts = Fontcustom::Options.new opts
  Fontcustom::Generator::Font.start [opts]
  Fontcustom::Generator::Template.start [opts]
end

# in generator/font.rb
def example
  puts "#{opts.font_name} is sweet."
end
```

3. Options as a class (transitional)
  - switch over to Options.new, instead of using the class directly
  - initialize with @shell and @opts (self)
  - #collect_options should convert class to hash 

4. Improve messages
  - Messages for improper config, default settings, etc.
  - Handle all errors through say_status
  - Colors for thor :say

5. Options as a class (full)
  - move #collect_options into initialize

6. CLI should store default options
  - when reading options from config, only overwrite default options

