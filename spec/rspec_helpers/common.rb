# frozen_string_literal: true

module RSpecHelpers
  module Common
    def opened_tmp_files
      `ls -g /proc/#{$PID}/fd`.split("\n").map(&:split).select do |values|
        values.size > 2 && values.last.start_with?('/tmp/')
      end
    end

    def opened_tmp_files_count
      opened_tmp_files.size
    end
  end
end
