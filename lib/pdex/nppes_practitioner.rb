module PDEX
  class NPPESPractitioner
    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data.freeze
    end

    def npi
      @raw_data['NPI']
    end

    def name
      OpenStruct.new(
        {
          first: @raw_data['Provider First Name'].capitalize,
          middle: @raw_data['Provider Middle Name'].capitalize,
          last: @raw_data['Provider Last Name (Legal Name)'].capitalize,
          prefix: @raw_data['Provider Name Prefix Text'].capitalize,
          suffix: @raw_data['Provider Name Suffix Text'].capitalize,
          credential: @raw_data['Provider Credential Text']
        }
      )
    end

    def phone_numbers
      phone_number_1 = format_phone_number(@raw_data['Provider Business Mailing Address Telephone Number'])
      phone_number_2 = format_phone_number(@raw_data['Provider Business Practice Location Address Telephone Number'])
      [phone_number_1, phone_number_2].uniq
    end

    def fax_numbers
      fax_number_1 = format_phone_number(@raw_data['Provider Business Mailing Address Fax Number'])
      fax_number_2 = format_phone_number(@raw_data['Provider Business Practice Location Address Fax Number'])
      [fax_number_1, fax_number_2].uniq
    end

    def format_phone_number(number)
      return '5555555555' if number.blank?
      return number.gsub(/[^\d]/, '')
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

    def gender
      @raw_data['Provider Gender Code']
    end

    def qualifications
      (1..50).map { |index| qualification(index) }.compact
    end

    def qualification(index)
      keys = [
        "Healthcare Provider Taxonomy Code_#{index}",
	      "Provider License Number_#{index}",
	      "Provider License Number State Code_#{index}"
      ]

      return nil if keys.any? { |key| @raw_data[key].blank? }

      OpenStruct.new(
        {
          state: @raw_data["Provider License Number State Code_#{index}"],
          license_number: @raw_data["Provider License Number_#{index}"],
          taxonomy_code: @raw_data["Healthcare Provider Taxonomy Code_#{index}"]
        }
      )
    end
  end
end
