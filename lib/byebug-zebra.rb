require 'byebug-zebra/version'
require 'byebug-zebra/config'
require 'byebug-zebra/byebug/printer'
require 'byebug/zebra_command'
#require 'pry/z_command' if defined? PryByebug

# TODO: exception extending policy?
# class Error < StandardError; end

module ByebugZebra
  # TODO: make configuration more consistent

  def self.config
    @config ||= Config.new
    block_given? ? yield(@config) : @config
  end
end
