require_relative './lat_long'

module PDEX
  module Position
    def position
      #puts "address.lines.first = #{address.lines.first}"

      coords = COORDINATES[address.lines.first]

      if address.lines.first != nil and coords.blank?
        # remove any suite number from address
        addr_string = String.new(address.lines.first)
        end_pos = addr_string.index(/[;, ] ?(SUITE|STE) /i)
        if end_pos != nil and end_pos > 0
          #puts "address with suite number: #{addr_string}"
          addr_string = addr_string[0,end_pos]
          #puts "address without suite number: #{addr_string}"
          coords = COORDINATES[addr_string]
        end
      end

      return if coords.blank?
      {
        longitude: coords[:x],
        latitude: coords[:y]
      }
    end
  end
end
