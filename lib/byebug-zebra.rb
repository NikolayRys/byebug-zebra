require 'byebug-zebra/version'
require 'byebug-zebra/config'
require 'byebug-zebra/byebug_printer'
require 'byebug/zebra_command'
#require 'pry/z_command' if defined? PryByebug

# TODO: exception extending policy?
# class Error < StandardError; end

module ByebugZebra

  class << self
    def config
      @config ||= Config.new
      block_given? ? yield(@config) : @config
    end

    attr_reader :ignored_origins

    def ignored_origins
      @ignored_origins ||= []
    end
  end
end
