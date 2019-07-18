module PDEX
  module Formatting
    def format_phone_number(number)
      return '5555555555' if number.blank?
      return number.gsub(/[^\d]/, '')
    end

    def format_for_url(string)
      string.gsub(/[^\w\s]/, '').gsub(/[\W]/, '-').downcase
    end
  end
end
