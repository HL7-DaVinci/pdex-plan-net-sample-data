require 'faker'
require_relative 'utils/formatting'

module PDEX
  class NPPESNetwork
    include Formatting

    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data.freeze
    end

    def npi
      raw_data['hpid']
    end

    def type
      {
        code: raw_data['prov_type_code'],
        display: raw_data['prov_type_display'],
        text: raw_data['prov_type_text']
      }
    end

    def name
      raw_data['name']
    end

    def phone_numbers
      [format_phone_number(raw_data['phone'])]
    end

    def fax_numbers
      []
    end

    def address
      OpenStruct.new(
        {
          lines: [raw_data['address']],
          city: raw_data['city'],
          state: raw_data['state'],
          zip: format_zip(raw_data['zip'])
        }
      )
    end

    def contact_first_name
      Faker::Name.first_name
    end

    def contact_last_name
      Faker::Name.last_name
    end

    def part_of_id
      raw_data['partof_id']
    end

    def part_of_name
      raw_data['partof_display']
    end
  end
end
