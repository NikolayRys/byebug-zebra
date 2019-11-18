require 'colorized_string'

module ByebugZebra
  class Config

    # Colors that can be used: ColorizedString.colors
    attr_accessor :color, :root, :known_paths, :odd_color, :even_color, :warn_color

    def initialize
      @color = true
      @root = defined?(Rails) ? Rails.root.to_s : nil
      @known_paths = {}
      @odd_color = :light_white
      @even_color = :black
      @warn_color = :red
    end

    ROOT_WARNING = <<-DESCRIPTION
    WARNING: application root directory is not set, thus using Dir.pwd. p
             Please specify the correct path via the config:
             ByebugZebra.config do |config|
               config.root = '/abs/path/to/your/app'
             end
    DESCRIPTION

    def enforce_root
      unless @root
        msg = color ? ColorizedString[ROOT_WARNING].colorize(warn_color) : ROOT_WARNING
        print msg # TODO: puts?
        @root = Dir.pwd
      end
    end

  end

end
