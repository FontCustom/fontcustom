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

4. Improve messages
  - Ensure that verbose: false is silent

5. Options as a class (full)
  - move #collect_options into initialize

6. CLI should store default options
  - when reading options from config, only overwrite default options

Bonus:
  - Configure colors for thor say
  - Error message if fontforge isn't installed
