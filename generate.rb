require 'csv'
require 'pry'
require_relative 'lib/pdex'
require_relative 'lib/pdex/nppes_network'
require_relative 'lib/pdex/nppes_organization'
require_relative 'lib/pdex/nppes_plan'
require_relative 'lib/pdex/nppes_practitioner'
require_relative 'lib/pdex/endpoint_factory'
require_relative 'lib/pdex/insurance_plan_factory'
require_relative 'lib/pdex/location_factory'
require_relative 'lib/pdex/network_factory'
require_relative 'lib/pdex/organization_factory'
require_relative 'lib/pdex/practitioner_factory'

nppes_dir = 'sample-nppes-data'

managing_organization_filenames = File.join(nppes_dir, 'managing_orgs_data.csv')
organization_filenames = File.join(nppes_dir, 'sample-nppes-organization-data.csv')
practitioner_filenames = File.join(nppes_dir, 'sample-nppes-practitioner_20181204-data.csv')
network_filenames = File.join(nppes_dir, 'sample-nppes-network_20181204-data.csv')

plan_data = []
organization_data = []
practitioner_data = []
network_data = []

FileUtils.mkdir_p('output/InsurancePlan')
CSV.foreach(managing_organization_filenames, headers: true) do |row|
  next unless row['is_plan'].downcase == 'true' && row['type'].downcase == 'ins'
  plan_data << nppes_data = PDEX::NPPESPlan.new(row)
  resource = PDEX::InsurancePlanFactory.new(nppes_data).build
  File.write("output/InsurancePlan/#{resource.id}.json", resource.to_json)
end

FileUtils.mkdir_p('output/Organization')
FileUtils.mkdir_p('output/Location')
FileUtils.mkdir_p('output/Endpoint')
CSV.foreach(organization_filenames, headers: true) do |row|
  organization_data << nppes_data = PDEX::NPPESOrganization.new(row)
  resource = PDEX::OrganizationFactory.new(nppes_data).build
  File.write("output/Organization/#{resource.id}.json", resource.to_json)

  resource = PDEX::LocationFactory.new(nppes_data).build
  File.write("output/Location/#{resource.id}.json", resource.to_json)

  resource = PDEX::EndpointFactory.new(nppes_data, 'Organization').build
  File.write("output/Endpoint/#{resource.id}.json", resource.to_json)
end

FileUtils.mkdir_p('output/Practitioner')
CSV.foreach(practitioner_filenames, headers: true) do |row|
  practitioner_data << nppes_data = PDEX::NPPESPractitioner.new(row)
  resource = PDEX::PractitionerFactory.new(nppes_data).build
  File.write("output/Practitioner/#{resource.id}.json", resource.to_json)
end

FileUtils.mkdir_p('output/Network')
CSV.foreach(network_filenames, headers: true) do |row|
  network_data << nppes_data = PDEX::NPPESNetwork.new(row)
  resource = PDEX::NetworkFactory.new(nppes_data).build
  File.write("output/Network/#{resource.id}.json", resource.to_json)
end
