#$LOAD_PATH.unshift '/Users/nikolay/development/'

#require_relative 'lib/byebug'
#require 'pry'
require 'byebug'
require "byebug/core"
#byebug
require 'byebug-zebra'
#require 'pry'
# binding.pry


require_relative '../zebratest/lib1.rb'

ByebugZebra.config do |config|
  #config.root = Dir.pwd
  config.known_libs = {lib1: '/Users/nikolay/development/zebratest/lib1.rb'}
end

def outer_method
  lib1_outer do
    inner_method
  end
end

def inner_method
  byebug
end


outer_method
