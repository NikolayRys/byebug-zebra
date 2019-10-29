# frozen_string_literal: true
require 'byebug/command'
require 'byebug/helpers/frame'

module Smarttrace
  #
  # Show current backtrace with .
  #
  class ByebugSmarttrace < Byebug::Command
    include Helpers::FrameHelper

    self.allow_in_post_mortem = true

    def self.regexp
      /^\s* (st|smarttrace) \s*$/x
    end

    def self.description
      <<-DESCRIPTION
        st|backtrace

        #{short_description}

        Improved version of the where/backtrace command. 
        Print the entire stack frame. Each frame is numbered; the most recent
        frame is 0. A frame number can be referred to in the "frame" command.
        "up" and "down" add or subtract respectively to frame numbers shown.
        The position of the current frame is marked with -->. C-frames hang
        from their most immediate Ruby frame to indicate that they are not
        navigable.
      DESCRIPTION
    end

    def self.short_description
      'Displays the backtrace with the origin of each frame'
    end

    def execute
      print_backtrace
    end

    private

    def print_backtrace
      bt = prc("frame.line_with_lib", (0...context.stack_size)) do |_, index|
        Frame.new(context, index).to_hash
      end

      print(bt)
    end
  end
end


