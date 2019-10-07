require_relative 'utils/formatting'
require_relative 'utils/fakes'
require_relative 'utils/lat_long'
require_relative 'utils/position'

module PDEX
  class PharmacyOrgData
    include Formatting
    include Fakes
    include Position

    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data.freeze
    end

    def npi
      # return the id
    end

    def name
      # return the name
    end

    def phone_numbers
      @phone_numbers ||= [fake_phone_number]
    end

    def fax_numbers
      @fax_numbers ||= [fake_phone_number]
    end

    def address
      # return a fake address, or don't if we don't need an address for the orgs
      OpenStruct.new(
        {
          lines: [
          ],
          city: '',
          state: '',
          zip: format_zip('')
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
