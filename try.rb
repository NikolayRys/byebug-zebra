#require_relative 'lib/byebug'

require 'byebug'
#require 'pry'
#require 'pry-byebug'
require 'byebug-zebra'


# binding.pry

# ByebugZebra.config do |config|
#   #config.root = Dir.pwd
#   config.known_libs = {lib1: '/Users/nikolay/development/zebratest/lib1.rb'}
# end

require_relative '../zebratest/lib1.rb'



def outer_method
  lib1_outer do
    inner_method
  end
end

def inner_method
  byebug
  binding.pry
end


outer_method
