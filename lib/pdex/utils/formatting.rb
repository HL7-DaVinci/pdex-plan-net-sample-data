module PDEX
  module Formatting
    def format_phone_number(number)
      return '5555555555' if number.blank?
      return number.gsub(/[^\d]/, '')
    end

    def format_zip(zip)
      return zip if zip.length == 5 || zip.length == 9 || zip.length == 10
      return zip.rjust(5, '0') if zip.length < 5
      zip[0..-5].rjust(5, '0') + zip[0..-4]
    end

    def format_for_url(string)
      string.gsub(/[^\w\s]/, '').gsub(/[\W]/, '-').downcase
    end
  end
end
