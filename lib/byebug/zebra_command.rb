# frozen_string_literal: true
require 'byebug/command'
require 'byebug/helpers/frame'

module Byebug
  # Show current backtrace with additional information about the source libraries.
  class ZebraCommand < Byebug::Command
    include Byebug::Helpers::FrameHelper

    self.allow_in_post_mortem = true

    def self.regexp
      /^\s* (z|zeb|zebra) \s*$/x
    end

    def self.description
      <<-DESCRIPTION
        z|zeb|zebra

        #{short_description}

        #{'Requires ByebugZebra.app_root to be set to work properly!'}

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
      'Displays the backtrace with the origin of each frame'
    end

    def execute
      config.ensure_root!
      # We are not using simply context.backtrace to preserve byebug's ignored_files feature
      ::ByebugZebra::ByebugPrinter.new(context.stack_size){ |index| Frame.new(context, index) }.print_striped_backtrace
    end

    private
    def config
      ByebugZebra.config
    end
  end
end


