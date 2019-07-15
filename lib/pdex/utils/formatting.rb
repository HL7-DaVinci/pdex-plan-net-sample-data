module PDEX
  module Formatting
    def format_phone_number(number)
      return '5555555555' if number.blank?
      return number.gsub(/[^\d]/, '')
    end
  end
end
