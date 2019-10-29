# frozen_string_literal: true
require 'pry-byebug/helpers/navigation'

module Smarttrace
  #
  # Display the current stack
  #
  class PrySmarttrace < Pry::ClassCommand
    include Helpers::Navigation

    match 'mytrace'
    group 'Byebug'

    description 'Display the current stack, improved.'

    banner <<-BANNER
      Usage: mytrace

      Display the current stack, improved.
    BANNER

    def process
      PryByebug.check_file_context(target)

      breakout_navigation :mytrace
    end
  end
end

Pry::Commands.add_command(Smarttrace::PrySmarttrace)
