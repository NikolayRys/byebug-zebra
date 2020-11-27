# Common stack frame source analyzer for byebug and pry-byebug

module ByebugZebra
  class Analyzer
    def initialize(backtrace)
      @backtrace = backtrace
    end

    def analyze(backtrace)
      # TODO: COMPARE BACKTRACES in byebug and pry-byebug
      # if no diff, make it for a frame
    end

    private
    def belongs_to_path?(target_path, root_path)
      # Is exactly this file or is in a subdirectory
      target_path.fnmatch?("#{root_path}{#{File::SEPARATOR}**,}", File::FNM_EXTGLOB)
    end

    def detect_stdlib_name(frame_path)
      if belongs_to_path?(frame_path, STDLIB_DIR)
        internal_subpath = frame_path.relative_path_from(STDLIB_DIR).to_s
        config.stdlib_names.detect{|name| internal_subpath.start_with?(name)}
      end
    end

    def analyze_origin(frame)
      # TODO: compare against $LOADED_FEATURES
      # TODO: refactor frame.file to frame_path
      frame_path = Pathname.new(frame.file)

      if frame.c_frame?
        [:native, frame.file]
      elsif (origin_pair = config.known_libs.detect{|_name, lib_path| belongs_to_path?(frame_path, lib_path)})
        [:lib, origin_pair.first]
      elsif belongs_to_path?(frame_path, config.root)
        [:application]
      elsif (gem_pair = @loaded_external_gems.detect{|_name, gem_path| belongs_to_path?(frame_path, gem_path) })
        [:gem, gem_pair.first]
      elsif false
        # TODO: Add vendor gems detection
      elsif (std_name = detect_stdlib_name(frame_path))
        [:stdlib, std_name]
      elsif belongs_to_path?(frame_path, RUBY_DIR)
        [:core, frame.file]
      else
        [:unknown, frame.file]
      end
    end

  end
end
