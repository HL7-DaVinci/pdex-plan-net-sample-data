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
  end
end
