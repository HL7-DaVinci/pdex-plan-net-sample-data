require_relative 'utils/formatting'

module PDEX
  class NPPESOrganization
    include Formatting

    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data.freeze
    end

    def npi
      @raw_data['NPI']
    end

    def name
      @raw_data['Provider Organization Name (Legal Business Name)']
    end

    def phone
      format_phone_number(@raw_data['Provider Business Mailing Address Telephone Number'])
    end

    def address
      OpenStruct.new(
        {
          lines: [
            @raw_data['Provider First Line Business Mailing Address'],
            @raw_data['Provider Second Line Business Mailing Address']
          ].reject(&:blank?),
          city: @raw_data['Provider Business Mailing Address City Name'],
          state: @raw_data['Provider Business Mailing Address State Name'],
          zip: @raw_data['Provider Business Mailing Address Postal Code']
        }
      )
    end
  end
end
