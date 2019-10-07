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

#managing_organization_filenames = File.join(data_dir, 'managing_orgs_data.csv')
#organization_filenames = File.join(data_dir, 'sample-nppes-organization-data.csv')
#practitioner_filenames = File.join(data_dir, 'sample-nppes-practitioner_20181204-data.csv')
#network_filenames = File.join(data_dir, 'sample-nppes-network_20181204-data.csv')
pharmacy_filenames = File.join(data_dir, 'ct_pharmacies.csv')

data = []

CSV.foreach(pharmacy_filenames, headers: true) do |row|
  data << PDEX::PharmacyData.new(row)
end

def short_name(name)
#   short_name = name.split(" ")[0].camelize
    short_name = name.partition("#")[0]
    short_name = short_name.partition("STORE")[0]
    short_name = short_name.partition("SUPERMARKET")[0]
    short_name = short_name.partition("OF")[0]
    short_name = short_name.partition("PHARMACY")[0]
   short_name_strip = short_name.rstrip
end
def pharm_org_out(name, pharms, id)
    {
        id: id,
        name: name,
        pharms: pharms 
    }
end

pharm_org_index = 0
count = {}
locations_to_orgs = {} 
pharms = data.map(&:name).each_with_object({}) do |pharmacy, pharm_orgs|
    org_name = short_name(pharmacy)
    if !count[org_name] || count[org_name]==0 then
        count[org_name] = pharm_org_index
        pharm_org_index = pharm_org_index + 1
        puts "pharmacy #{pharmacy}  --> short_name #{org_name}  number #{count[org_name]}"
        pharm_orgs[org_name] = []
    end
    pharm_orgs[org_name] << pharmacy
    locations_to_orgs[pharmacy] = org_name 
end
puts pharm_org_out("WALGREENS", pharms["WALGREENS"], count["WALGREENS"])

file = File.open('lib/pdex/utils/pharmorgs.rb', 'w') 
file.puts "PHARM_ORGS = "
pharms.each do |name, pharms|
    file.puts pharm_org_out(name, pharms, count[name])
end

file = File.open('lib/pdex/utils/pharms_to_pharmmorgs.rb', 'w') 
file.puts "PHARMS_TO_PHARMORGS = "
file.puts locations_to_orgs 
