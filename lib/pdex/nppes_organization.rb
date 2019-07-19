require_relative 'utils/formatting'

module PDEX
  class NPPESOrganization
    include Formatting

    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data.freeze
    end

    def npi
      raw_data['NPI']
    end

    def name
      raw_data['Provider Organization Name (Legal Business Name)']
    end

    def phone_numbers
      phone_number_1 = format_phone_number(raw_data['Provider Business Mailing Address Telephone Number'])
      phone_number_2 = format_phone_number(raw_data['Provider Business Practice Location Address Telephone Number'])
      [phone_number_1, phone_number_2].uniq
    end

    def fax_numbers
      fax_number_1 = format_phone_number(raw_data['Provider Business Mailing Address Fax Number'])
      fax_number_2 = format_phone_number(raw_data['Provider Business Practice Location Address Fax Number'])
      [fax_number_1, fax_number_2].uniq
    end

    def address
      OpenStruct.new(
        {
          lines: [
            raw_data['Provider First Line Business Mailing Address'],
            raw_data['Provider Second Line Business Mailing Address']
          ].reject(&:blank?),
          city: raw_data['Provider Business Mailing Address City Name'],
          state: raw_data['Provider Business Mailing Address State Name'],
          zip: format_zip(raw_data['Provider Business Mailing Address Postal Code'])
        }
      )
    end
  end
end
