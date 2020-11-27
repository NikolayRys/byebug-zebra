# ByebugZebra
![logo.png](logo.png)

Start stack trace analyzer and navigator for Byebug, Pry and PryByebug. Alpha version.

## Installation

Add this line to your application's Gemfile:

```ruby
require 'byebug'
require 'byebug-zebra'
```

## Usage
Place a debugger statement:
```
# some code
byebug
# some more code
```
When the execution stops, just type `zebra` to see analyzed backtrace for the current position.

# Configuration
If you have dependencies in usual custom paths, you can let Zebra know through the config.
Also it's helpful to configure the default path of the application:
```
ByebugZebra.config do |config|
  config.root = '/abs/path/to/your/app'
  config.known_paths['my_lib'] = '/abs/path/to/my_lib'
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NikolayRys/byebug-zebra.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
