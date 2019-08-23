module PDEX
  module Address
    def address
      lines = source_data.address.lines
      city = source_data.address.city
      state = source_data.address.state
      zip = source_data.address.zip
      text = [lines, "#{city}, #{state} #{zip}"].flatten.join(', ')
      {
        use: 'work',
        type: 'both',
        text: text,
        line: lines,
        city: city,
        state: state,
        postalCode: zip,
        country: 'USA'
      }
    end

    def address_with_geolocation
      return address if source_data.position.blank?
      address.merge(
        extension: [
          {
            url: 'http://hl7.org/fhir/StructureDefinition/geolocation',
            extension: [
              {
                url: 'latitude',
                valueDecimal: source_data.position[:latitude]
              },
              {
                url: 'longitude',
                valueDecimal: source_data.position[:longitude]
              },
            ]
          }
        ]
      )
    end
  end
end
