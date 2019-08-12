require 'csv'
require 'pry'
require_relative 'lib/pdex'
require_relative 'lib/pdex/nppes_network'
require_relative 'lib/pdex/nppes_organization'
require_relative 'lib/pdex/nppes_plan'
require_relative 'lib/pdex/nppes_practitioner'
require_relative 'lib/pdex/utils/nucc_codes'
require_relative 'lib/pdex/endpoint_factory'
require_relative 'lib/pdex/healthcare_service_factory'
require_relative 'lib/pdex/insurance_plan_factory'
require_relative 'lib/pdex/location_factory'
require_relative 'lib/pdex/network_factory'
require_relative 'lib/pdex/organization_affiliation_factory'
require_relative 'lib/pdex/organization_factory'
require_relative 'lib/pdex/practitioner_factory'
require_relative 'lib/pdex/practitioner_role_factory'

nppes_dir = 'sample-nppes-data'

managing_organization_filenames = File.join(nppes_dir, 'managing_orgs_data.csv')
organization_filenames = File.join(nppes_dir, 'sample-nppes-organization-data.csv')
practitioner_filenames = File.join(nppes_dir, 'sample-nppes-practitioner_20181204-data.csv')
network_filenames = File.join(nppes_dir, 'sample-nppes-network_20181204-data.csv')

plan_data = []
organization_data = []
practitioner_data = []
network_data = []

networks = []
organizations = []
practitioners = []

FileUtils.mkdir_p('output/InsurancePlan')
CSV.foreach(managing_organization_filenames, headers: true) do |row|
  next unless row['is_plan'].downcase == 'true' && row['type'].downcase == 'ins'
  plan_data << nppes_data = PDEX::NPPESPlan.new(row)
  resource = PDEX::InsurancePlanFactory.new(nppes_data).build
  File.write("output/InsurancePlan/#{resource.id}.json", resource.to_json)
end

FileUtils.mkdir_p('output/Network')
CSV.foreach(network_filenames, headers: true) do |row|
  network_data << nppes_data = PDEX::NPPESNetwork.new(row)
  networks << resource = PDEX::NetworkFactory.new(nppes_data).build
  File.write("output/Network/#{resource.id}.json", resource.to_json)
end

FileUtils.mkdir_p('output/Organization')
FileUtils.mkdir_p('output/OrganizationAffiliation')
FileUtils.mkdir_p('output/Location')
FileUtils.mkdir_p('output/Endpoint')
FileUtils.mkdir_p('output/HealthcareService')
CSV.foreach(organization_filenames, headers: true) do |row|
  organization_data << nppes_data = PDEX::NPPESOrganization.new(row)
  organizations << resource = PDEX::OrganizationFactory.new(nppes_data).build
  File.write("output/Organization/#{resource.id}.json", resource.to_json)

  resource = PDEX::LocationFactory.new(nppes_data).build
  File.write("output/Location/#{resource.id}.json", resource.to_json)

  resource = PDEX::EndpointFactory.new(nppes_data, 'Organization').build
  File.write("output/Endpoint/#{resource.id}.json", resource.to_json)

  networks = network_data.select { |network| network.address.state == nppes_data.address.state }
  next if networks.empty?
  resource = PDEX::OrganizationAffiliationFactory.new(nppes_data, network: networks.sample).build
  File.write("output/OrganizationAffiliation/#{resource.id}.json", resource.to_json)

  PDEX::NUCCConstants::SERVICE_LIST.each do |service|
    resource = PDEX::HealthcareServiceFactory.new(nppes_data, service).build
    File.write("output/HealthcareService/#{resource.id}.json", resource.to_json)
  end
end

FileUtils.mkdir_p('output/Practitioner')
FileUtils.mkdir_p('output/PractitionerRole')
CSV.foreach(practitioner_filenames, headers: true) do |row|
  practitioner_data << nppes_data = PDEX::NPPESPractitioner.new(row)
  practitioners << resource = PDEX::PractitionerFactory.new(nppes_data).build
  File.write("output/Practitioner/#{resource.id}.json", resource.to_json)

  zip_code = nppes_data.address.zip
  organizations = organization_data.select do |organization|
    organization.address.zip == zip_code
  end
  next if organizations.empty?
  resource = PDEX::PractitionerRoleFactory.new(nppes_data, organization: organizations.sample).build
  File.write("output/PractitionerRole/#{resource.id}.json", resource.to_json)
end

