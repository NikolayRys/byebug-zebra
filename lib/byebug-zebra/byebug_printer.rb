require 'colorized_string'

module ByebugZebra
  class Printer

    def initialize(stack_size, &frame_block)
      @stack_size = stack_size
      @frame_block = frame_block
      @odd_scheme = { color: config.odd_color, background: config.even_color }
      @even_scheme = { color: config.even_color, background: config.odd_color }
      @has_unknown_origin = false
    end

    def print_striped_backtrace
      current_origin = nil
      current_oddness = false

      @stack_size.times do |i|
        frame = @frame_block.call(i)
        if current_origin != frame.origin
          current_oddness = !current_oddness
          current_origin = frame.origin
        end
        puts frame_str(frame, current_oddness)
      end
      puts to_warn(ORIGIN_WARNING) if @has_unknown_origin
    end

    ORIGIN_WARNING = 'WARNING: Paths of some stack frames have not been recognized. They are highlighted as this line.'
    INFO_TEMPLATE  = '%{call} at %{file}:%{line}'
    private
    def frame_str(frame, odd)
      frame_data = frame.to_hash
      origin, info_str = analyze_origin(frame.file, INFO_TEMPLATE % frame_data)
      num_content = "##{frame_data[:pos]}"
      num_str = colorize(num_content, odd ? @odd_scheme : @even_scheme)
      "#{frame_data[:mark]} #{num_str} #{info_str} by #{origin}"
    end

    def analyze_origin(frame_file, info_content)
      abs_path = File.expand_path(frame_file)
      known_origin_pair = config.known_libs.detect{|_name, path| abs_path.include?(path)}

      if known_origin_pair
        { origin: "LIB: #{known_origin_pair.first}", info_str: info_content }
      else
        if abs_path.include?(config.root)
          { origin: 'APPLICATION', info_str: ColorizedString[info_content].bold }
        else
          identified_gem_spec_pair = Gem.loaded_specs.detect{|_name, spec| abs_path.include?(spec.full_gem_path) }
          if identified_gem_spec_pair
            { origin: "GEM: #{identified_gem_spec_pair.first}", info_str: info_content }
          else
            @has_unknown_origin = true
            { origin: 'UNKNOWN', info_str: to_warn(info_content) }
          end
        end
      end
    end

    def colorize(text, color)
      config.color ? ColorizedString[text].colorize(color) : text
    end

    def to_warn(text)
      colorize(ColorizedString[text].italic, config.warn_color)
    end

    def config
      ByebugZebra.config
    end

  end
end
