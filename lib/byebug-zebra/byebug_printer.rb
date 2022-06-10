require 'colorized_string'
require 'tty-prompt'
require 'byebug-zebra/analyzer'

# TODO: use Pathname for paths

module ByebugZebra
  class ByebugPrinter

    ORIGIN_WARNING  = <<-TEXT
WARNING: This origin is not known to zebra. Please add it to the config file. Example:
  ByebugZebra.config do |config|
    config.known_libs = {lib1: '/abs/path/to/your/lib1', lib2: '/abs/path/to/your/lib2' }
  end
TEXT

    def initialize(context)
      @context = context

      # TODO: cache on load in config

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

    def print_zebra_stacktrace
      prev_origin = nil
      odd = false
      unknown_detected = false

      @origins = []

      parsed_frames = []
      @context.stack_size.times do |index|
        frame = Byebug::Frame.new(@context, index)
        origin = Analyzer.examine_frame(frame) # Move to the module
        @origins << origin

        unknown_detected = true if origin.first == :unknown
        odd = !odd unless origin == prev_origin
        prev_origin = origin
        # TODO: make Zebra::Frame into a class
        parsed_frames << str_parts(frame, origin).concat([origin, odd])
      end
      print_unknown_warning if unknown_detected
      # TODO: switch to the named arguments and hash syntax
      parsed_frames.each { |frame_args| print_frame_line(*frame_args) if config.ignored_origins.exclude?(frame_args[2]) }

      filter_prompt

    end

    private

    def print_unknown_warning
      STDOUT.puts(ColorizedString[ORIGIN_WARNING].colorize(config.warn_color))
    end

    TTY_COUNT_OFFSET = 1

    def filter_prompt
      selection = TTY::Prompt.new.multi_select('Which sources should zebra ignore?', cycle: true, quiet: true) do |menu|
        preselected = []
        @origins.uniq.each.with_index(TTY_COUNT_OFFSET) do |origin, index|
          preselected << index if config.ignored_origins.include?(origin)
          menu.choice(name: origin, value: origin) # Because name becomes a string
        end
        menu.default(*preselected)
      end

      config.ignored_origins = selection
    end

    def str_parts(frame, origin)
      frame_hash = frame.to_hash
      origin_str = case origin.first
      when :gem, :lib, :stdlib
        "#{origin.first.to_s.upcase}: #{origin.last}"
      else
        origin.first.to_s.upcase
      end
      # ["#{frame_hash[:mark]} ##{frame_hash[:pos]} ",
      #  "#{frame_hash[:call]} at #{frame_hash[:file]}:#{frame_hash[:line]} from #{origin_str}"]
      ["#{frame_hash[:mark]} ##{frame_hash[:pos]} from #{origin_str}: ",
       "#{frame_hash[:call]}"]
    end

    def print_frame_line(prefix_str, info_str, origin, odd)
      scheme_group = odd ? :odd : :even
      info_scheme = [:application, :unknown].include?(origin.first) ? origin.first : :basic

      puts ColorizedString[prefix_str].colorize(@schemes[scheme_group][:basic]) +
        ColorizedString[info_str].colorize(@schemes[scheme_group][info_scheme])
    end

    def config
      ByebugZebra.config
    end
  end
end
