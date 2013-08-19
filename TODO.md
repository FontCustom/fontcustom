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

2. actions.rb => util.rb (module)
  - should not auto-include Thor::Actions
  - may need to include its own Thor::Shell

3. CLI should store default options
  - when reading options from config, only overwrite default options

4. Options as a class
  - use the new FC::Util module instead of Thor (just to get @shell)

# Misc

* Messages for improper config, default settings, etc.
* Handle all errors through say_status
* Colors for thor :say
