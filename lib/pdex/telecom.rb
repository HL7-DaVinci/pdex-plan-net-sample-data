module PDEX
  module Telecom
    def telecom
      phone_entries = source_data.phone_numbers.map { |phone| telecom_entry('phone', phone) }
      fax_entries = source_data.fax_numbers.map { |fax| telecom_entry('fax', fax) }
      phone_entries + fax_entries
    end

    def telecom_entry(type, number)
      {
        system: type,
        value: number,
        use: 'work'
      }
    end
  end
end
