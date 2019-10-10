require_relative 'utils/formatting'
require_relative 'utils/fakes'
require_relative 'utils/lat_long'
require_relative 'utils/position'

module PDEX
  class PharmacyData
    include Formatting
    include Fakes
    include Position

    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data.freeze
    end

    def npi
      @credential ||= fake_pharmacy_credential(raw_data['Credential'].gsub(".","-"))
    end

    def name
      raw_data['Pharmacy-Name']
    end

    def phone_numbers
      @phone_numbers ||= [fake_phone_number]
    end

    def fax_numbers
      @fax_numbers ||= [fake_phone_number]
    end

    def address
      OpenStruct.new(
        {
          lines: [
            raw_data['Address']
          ],
          city: raw_data['City'],
          state: raw_data['State'],
          zip: format_zip(raw_data['Zip'])
        }
      )
    end

    def contact_first_name
      @contact_first_name ||= fake_first_name
    end

    def contact_last_name
      @contact_last_name ||= fake_family_name
    end
  end
end
