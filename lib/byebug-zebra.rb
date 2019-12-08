require 'byebug-zebra/version'
require 'byebug-zebra/config'
require 'byebug-zebra/byebug_printer'
require 'byebug-zebra/path_normalizer'
require 'byebug/zebra_command'
#require 'pry/z_command' if defined? PryByebug

# TODO: exception extending policy?
# class Error < StandardError; end

module ByebugZebra
  def self.config
    @config ||= Config.new
    block_given? ? yield(@config) : @config
  end
end
