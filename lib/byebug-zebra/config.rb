require 'colorized_string'

module ByebugZebra
  class Config

    # Colors that can be used: ColorizedString.colors
    attr_accessor :color, :root, :known_libs, :odd_color, :even_color, :warn_color

    def initialize
      @color = true
      @root = defined?(Rails) ? Rails.root.to_s : nil
      @known_libs = {}
      @odd_color = :light_white
      @even_color = :black
      @warn_color = :red
    end

    ROOT_WARNING = <<-DESCRIPTION
WARNING: application root directory is not set, using Dir.pwd. Specify the correct root:
         ByebugZebra.config do |config|
           config.root = '/abs/path/to/your/app'
         end
    DESCRIPTION

    def enforce_root!
      unless @root

        print(color ? ColorizedString[ROOT_WARNING].colorize(warn_color) : ROOT_WARNING)
        @root = Dir.pwd
      end
    end

  end

end
