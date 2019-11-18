require 'colorized_string'

module ByebugZebra
  class ByebugPrinter

    def initialize(stack_size, &frame_block)
      @stack_size     = stack_size
      @frame_block    = frame_block
      @odd_scheme     = { color: config.odd_color, background: config.even_color }
      @even_scheme    = { color: config.even_color, background: config.odd_color }
      @unknown_origin = false
    end

    def print_striped_backtrace
      current_origin = nil
      current_oddness = false

      @stack_size.times do |i|
        frame_hash = get_frame_hash_with_origin(@frame_block.call(i))
        unless current_origin == frame_hash[:origin]  ## OR UNKNOWN
          current_oddness = !current_oddness
          current_origin = frame_hash[:origin]
        end
        puts frame_str(frame_hash, current_oddness)
      end
      puts to_warn(ORIGIN_WARNING) if @unknown_origin
    end

    ORIGIN_WARNING = 'WARNING: Origin of some stack frames have not been recognized. Please provide paths for them.'
    INFO_TEMPLATE  = '%{call} at %{file}:%{line}'
    NUM_TEMPLATE   = '#%{pos}'
    FRAME_TEMPLATE = '%{mark} %{num_str} %{info_str} in %{origin}'

    private
    def frame_str(frame_hash, odd)
      frame_hash[:num_str] = NUM_TEMPLATE % frame_hash
      colorize(FRAME_TEMPLATE % frame_hash, odd ? @odd_scheme : @even_scheme)
    end

    def get_frame_hash_with_origin(frame)
      frame_hash = frame.to_hash
      info_content = INFO_TEMPLATE % frame_hash

      frame_path = File.expand_path(frame.file)
      if origin_pair = config.known_libs.detect{|_name, libpath| is_subpath?(frame_path, libpath)}
        frame_hash[:origin]   = "LIB (#{origin_pair.first})"
        frame_hash[:info_str] = info_content
      elsif is_subpath?(frame_path, config.root)
        frame_hash[:origin]   = 'APPLICATION'
        frame_hash[:info_str] = ColorizedString[info_content].bold
      elsif gem_spec_pair = Gem.loaded_specs.detect{|_name, gemspec| is_subpath?(frame_path, gemspec.full_gem_path) }
        frame_hash[:origin]   = "GEM (#{gem_spec_pair.first})"
        frame_hash[:info_str] = info_content
      elsif is_subpath?(frame_path, RbConfig::CONFIG['rubylibdir'])
        frame_hash[:origin]   = 'STDLIB'
        frame_hash[:info_str] = info_content
      else
        @unknown_origin       = true
        frame_hash[:origin]   = 'UNKNOWN'
        frame_hash[:info_str] = to_warn(info_content)
      end
      frame_hash
    end

    def is_subpath?( target, root )
      real_root = File.realpath(root) rescue nil
      real_root && target.start_with?(real_root)
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
