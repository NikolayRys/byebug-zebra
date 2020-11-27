# frozen_string_literal: true
require 'byebug/command'
require 'byebug/helpers/frame'
require 'tty-prompt'

module Byebug
  # Show current backtrace with additional information about the source libraries.
  class ZebraCommand < Byebug::Command
    include Byebug::Helpers::FrameHelper

    self.allow_in_post_mortem = true

    def self.regexp
      /^\s* (ig|ignore|zebra-ignore) \s*$/x
    end

    def self.description
      <<-DESCRIPTION
        ig|ignore|zebra-ignore

        #{short_description}

        #{'Requires ByebugZebra.root to be set to work properly!'}

        Improved version of the where/backtrace command. Originates from byebug-zebra gem.

        Print the entire stack frame. Each frame is numbered; the most recent
        frame is 0. A frame number can be referred to in the "frame" command.
        "up" and "down" add or subtract respectively to frame numbers shown.
        The position of the current frame is marked with -->. C-frames hang
        from their most immediate Ruby frame to indicate that they are not
        navigable.

        You can adjust colors and add your own library locations.
      DESCRIPTION
    end

    def self.short_description
      'Used to filter out source files that clutter the backtrace'
    end

    def execute


    end

    private
    def config
      ByebugZebra.config
    end
  end
end


