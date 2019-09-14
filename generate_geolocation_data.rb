require 'httparty'
require 'pry'

require_relative 'lib/pdex'
require_relative 'lib/pdex/nppes_network'
require_relative 'lib/pdex/nppes_organization'
require_relative 'lib/pdex/nppes_managing_org'
require_relative 'lib/pdex/nppes_practitioner'

nppes_dir = 'sample-nppes-data'

managing_organization_filenames = File.join(nppes_dir, 'managing_orgs_data.csv')
organization_filenames = File.join(nppes_dir, 'sample-nppes-organization-data.csv')
practitioner_filenames = File.join(nppes_dir, 'sample-nppes-practitioner_20181204-data.csv')
network_filenames = File.join(nppes_dir, 'sample-nppes-network_20181204-data.csv')

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

def get_coords(address)
  address_line = "#{address.lines.first}, #{address.city}, #{address.state} #{address.zip}"
  # https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html
  response = HTTParty.get(
    'https://geocoding.geo.census.gov/geocoder/locations/onelineaddress',
    query: {
      address: address_line,
      benchmark: 'Public_AR_Current',
      format: 'json'
    }
  )
  response.deep_symbolize_keys&.dig(:result, :addressMatches)&.first&.dig(:coordinates)
end

lat_long = data.map(&:address).each_with_object({}) do |address, addresses|
  coords = get_coords(address)
  print coords.present? ? '.' : 'x'
  addresses[address.lines.first] = coords if coords
end

File.open('lib/pdex/utils/lat_long.rb', 'w') { |file| file.puts lat_long }
