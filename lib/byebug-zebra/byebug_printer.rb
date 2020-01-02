require 'colorized_string'
require 'tty-prompt'

module ByebugZebra
  class ByebugPrinter

    RUBY_DIR   = RbConfig::CONFIG['prefix']
    STDLIB_DIR = Pathname.new(RbConfig::CONFIG['rubylibdir'])

    ORIGIN_WARNING  = <<-DESCRIPTION
WARNING: Origin of some stack frames have not been recognized. Specify them in the config. Example:
  ByebugZebra.config do |config|
    config.known_libs = {lib1: '/abs/path/to/your/lib1', lib2: '/abs/path/to/your/lib2' }
  end
DESCRIPTION

    def initialize(stack_size, &frame_block)
      @stack_size     = stack_size
      @frame_block    = frame_block

      # TODO: cache on load
      @external_gems  = Gem.loaded_specs.values.reject(&:default_gem?).map{|spec| [spec.name, Pathname.new(spec.full_gem_path)]}

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
      @stack_size.times do |i|
        frame = @frame_block.call(i)
        origin = analyze_origin(frame)
        @origins << origin

        unknown_detected = true if origin.first == :unknown
        odd = !odd unless origin == prev_origin
        prev_origin = origin
        parsed_frames << str_parts(frame, origin).concat([origin, odd])
      end
      puts ColorizedString[ORIGIN_WARNING].colorize(config.warn_color) if unknown_detected
      parsed_frames.each { |frame_args| print_frame_line(*frame_args) }


      TTY::Prompt.new.multi_select('Which sources should zebra ignore?', cycle: true) do |menu|
        menu.default 1

        @origins.uniq.each do |origin|
          menu.choice origin
        end
      end
    end

    private

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
    def belongs?(target_path, root_path)
      # Is this exactly this file or a file in subdirectory
      target_path.fnmatch?("#{root_path}{#{File::SEPARATOR}**,}", File::FNM_EXTGLOB)
    end

    def stdlib?(frame_path)
      if belongs?(frame_path, STDLIB_DIR)
        internal_subpath = frame_path.relative_path_from(STDLIB_DIR).to_s
        config.stdlib_names.detect{|name| internal_subpath.start_with?(name)}
      end
    end

    def analyze_origin(frame)
      frame_path = Pathname.new(frame.file)
      if frame.c_frame?
        [:native, frame.file]
      elsif origin_pair = config.known_libs.detect{|_name, lib_path| belongs?(frame_path, lib_path)}
        [:lib, origin_pair.first]
      elsif belongs?(frame_path, config.root)
        [:application]
      elsif gem_pair = @external_gems.detect{|_name, gem_path| belongs?(frame_path, gem_path) }
        [:gem, gem_pair.first]
      elsif std_name = stdlib?(frame_path)
        [:stdlib, std_name]
      elsif belongs?(frame_path, RUBY_DIR)
        [:core, frame.file]
      else
        [:unknown, frame.file]
      end
    end
    # ---------

    def config
      ByebugZebra.config
    end
  end
end
