require 'colorized_string'

module ByebugZebra
  class Config

    # Colors that can be used: ColorizedString.colors
    attr_accessor :color, :root, :odd_color, :even_color, :warn_color, :normalize
    attr_reader :known_libs, :stdlib_names

    def initialize
      @color = true
      @root = defined?(Rails) ? Rails.root.to_s : nil
      @odd_color = :light_white
      @even_color = :light_black
      @warn_color = :red
      @normalize = false
      @known_libs = {}
      @stdlib_names = (Dir.entries(RbConfig::CONFIG['rubylibdir']) - ['.', '..', RbConfig::CONFIG['arch']]).map{|file| File.basename(file, File.extname(file))}.uniq
    end

    ROOT_WARNING = <<-DESCRIPTION
WARNING: application root directory is not set, using Dir.pwd. Please do it like so:
  ByebugZebra.config do |config|
    config.root = '/abs/path/to/your/app'
  end\n
    DESCRIPTION

    def ensure_root!
      unless @root
        print(color ? ColorizedString[ROOT_WARNING].colorize(warn_color) : ROOT_WARNING)
        @root = Dir.pwd
      end
    end

    def known_libs=(libs_hash)
      @known_libs = libs_hash.to_h.transform_values{|path| Pathname.new(File.realpath(path))}
    end

  end

end
