require 'colorized_string'
require 'tty-prompt'
require 'byebug-zebra/analyzer'

# TODO: use Pathname for paths

module ByebugZebra
  class ByebugPrinter

    RUBY_DIR   = RbConfig::CONFIG['prefix']
    STDLIB_DIR = Pathname.new(RbConfig::CONFIG['rubylibdir'])

    ORIGIN_WARNING  = <<-TEXT
WARNING: Origin of some stack frames have not been recognized. Specify them in the config. Example:
  ByebugZebra.config do |config|
    config.known_libs = {lib1: '/abs/path/to/your/lib1', lib2: '/abs/path/to/your/lib2' }
  end
TEXT

    def initialize(context)
      @context = context

      # TODO: cache on load in config
      @loaded_external_gems  = Gem.loaded_specs.values.reject(&:default_gem?).map{|spec| [spec.name, Pathname.new(spec.full_gem_path)]}

      @schemes = {
        odd: {
          basic: { color: config.even_color, background: config.odd_color },
          unknown: { color: config.warn_color, background: config.odd_color },
          application: { color: config.even_color, background: config.odd_color, mode: :italic }
        },
        even: {
          basic:  { color: config.odd_color, background: config.even_color },
          unknown: { color: config.warn_color, background: config.even_color },
          application: { color: config.odd_color, background: config.even_color, mode: :italic }
        }
      }
    end

    def print_striped_backtrace
      prev_origin = nil
      odd = false
      unknown_detected = false

      @origins = []

      parsed_frames = []
      @context.stack_size.times do |index|
        frame = Byebug::Frame.new(@context, index)
        origin = analyze_origin(frame) # Move to the module
        @origins << origin

        unknown_detected = true if origin.first == :unknown
        odd = !odd unless origin == prev_origin
        prev_origin = origin
        parsed_frames << str_parts(frame, origin).concat([origin, odd])
      end
      puts ColorizedString[ORIGIN_WARNING].colorize(config.warn_color) if unknown_detected
      parsed_frames.each { |frame_args| print_frame_line(*frame_args) }

      filter_prompt

    end

    private

    def filter_prompt
      TTY::Prompt.new.multi_select('Which sources should zebra ignore?', cycle: true) do |menu|
        menu.default 1

        @origins.uniq.each do |origin|
          menu.choice origin
        end
      end
    end

    def str_parts(frame, origin)
      frame_hash = frame.to_hash
      origin_str = case origin.first
      when :gem, :lib, :stdlib
        "#{origin.first.to_s.upcase}: #{origin.last}"
      else
        origin.first.to_s.upcase
      end
      ["#{frame_hash[:mark]} ##{frame_hash[:pos]} ",
       "#{frame_hash[:call]} at #{frame_hash[:file]}:#{frame_hash[:line]} from #{origin_str}"]
    end

    def print_frame_line(prefix_str, info_str, origin, odd)
      scheme_group = odd ? :odd : :even
      info_scheme = [:application, :unknown].include?(origin.first) ? origin.first : :basic

      puts ColorizedString[prefix_str].colorize(@schemes[scheme_group][:basic]) +
        ColorizedString[info_str].colorize(@schemes[scheme_group][info_scheme])
    end

    # TODO: move out to analyzer

    # ---------

    def config
      ByebugZebra.config
    end
  end
end
