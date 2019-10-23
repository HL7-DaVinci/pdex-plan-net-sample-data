require_relative 'utils/formatting'
require_relative 'utils/fakes'
require_relative 'utils/lat_long'
require_relative 'utils/position'

module PDEX
  class PharmacyOrgData
    include Formatting
    include Fakes
    include Position
    include ShortName

    attr_reader :name

    def initialize(name)
      @name = name 
    end

    def npi
      digest_short_name(@name)
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
