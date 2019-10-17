require 'httparty'
require 'pry'

require_relative 'lib/pdex'
require_relative 'lib/pdex/nppes_network'
require_relative 'lib/pdex/nppes_organization'
require_relative 'lib/pdex/nppes_managing_org'
require_relative 'lib/pdex/nppes_practitioner'
require_relative 'lib/pdex/pharmacy_data'
require_relative 'lib/pdex/utils/lat_long'

data_dir = 'sample-data'

managing_organization_filenames = File.join(data_dir, 'managing_orgs_data.csv')
organization_filenames = File.join(data_dir, 'sample-nppes-organization-data.csv')
practitioner_filenames = File.join(data_dir, 'sample-nppes-practitioner_20181204-data.csv')
network_filenames = File.join(data_dir, 'sample-nppes-network_20181204-data.csv')
pharmacy_filenames = File.join(data_dir, 'ct_pharmacies.csv')

data = []

CSV.foreach(managing_organization_filenames, headers: true) do |row|
  if row['is_plan'].downcase == 'true' && row['type'].downcase == 'ins'
    data << PDEX::NPPESManagingOrg.new(row)
  elsif row['type'].downcase == 'ins'
    data << PDEX::NPPESManagingOrg.new(row, payer: true)
  end
end


CSV.foreach(network_filenames, headers: true) do |row|
  data << PDEX::NPPESNetwork.new(row)
end

CSV.foreach(organization_filenames, headers: true) do |row|
  data << PDEX::NPPESOrganization.new(row)
end

CSV.foreach(practitioner_filenames, headers: true) do |row|
  data << PDEX::NPPESPractitioner.new(row)
end

CSV.foreach(pharmacy_filenames, headers: true) do |row|
  data << PDEX::PharmacyData.new(row)
end

# # Geolocation from US census
# def get_coords(address)
#   address_line = "#{address.lines.first}, #{address.city}, #{address.state} #{address.zip}"
#   # https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html
#   response = HTTParty.get(
#     'https://geocoding.geo.census.gov/geocoder/locations/onelineaddress',
#     query: {
#       address: address_line,
#       benchmark: 'Public_AR_Current',
#       format: 'json'
#     }
#   )
#   response.deep_symbolize_keys&.dig(:result, :addressMatches)&.first&.dig(:coordinates)
# end

# Geolocation from MapQuest
def get_coords(address)
  address_line = "#{address.lines.first}, #{address.city}, #{address.state} #{address.zip}"
  response = HTTParty.get(
    'http://open.mapquestapi.com/geocoding/v1/address',
    query: {
      key: 'A4F1XOyCcaGmSpgy2bLfQVD5MdJezF0S',
      location: address_line,
      thumbMaps: false,
    }
  )
  coords = response.deep_symbolize_keys&.dig(:results)&.first&.dig(:locations).first&.dig(:latLng)
  {
    x: coords[:lng],
    y: coords[:lat]
  }
end

lat_long = data.map(&:address).each_with_object({}) do |address, addresses|
  key = address.lines.first
  if COORDINATES.key? address.lines.first
    addresses[key] = COORDINATES[key]
    print '-'
    next
  end
  coords = get_coords(address)
  print coords.present? ? '.' : 'x'
  addresses[key] = coords if coords
end

File.open('lib/pdex/utils/lat_long.rb', 'w') { |file| file.puts lat_long }
