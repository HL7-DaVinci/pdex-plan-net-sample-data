require_relative 'nucc_constants'

module PDEX
  module NUCCCodes
    include NUCCConstants

    def self.display(code)
      CODES[code]
    end

    def self.specialties_display(specialty_type)
      return specialty_type if specialty_type == 'miscellaneous'

      specialty_codes(specialty_type)
        .map { |code| specialty_display(code) }
        .join(', ')
    end

    def self.specialty_codes(specialty_type)
      return [specialty_type] if specialty_type == 'miscellaneous'

      # binding.pry if SERVICE_CODES[specialty_type] == nil 

      SERVICE_CODES[specialty_type].flat_map do |code|
        if code.length > 4
          code
        else
          CODES.select { |key, _v| key.to_s.start_with? code }
            .keys
        end
      end
    end

    def self.specialty_display(code)
      return code.capitalize if code == 'miscellaneous'
      return 'general practice' unless SERVICE_DISPLAY.key? code

      specialization = SERVICE_DISPLAY[code][2]
      definition = SERVICE_DISPLAY[code][3]
      #if specialization.present? && definition.present?
      if  definition.present?
      #  "#{specialization}/#{definition}"
         "#{definition}"
      elsif specialization.present?
        specialization
      else
        'general practice'
      end
    end
  end
end
