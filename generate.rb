require 'csv'
require 'pry'
require_relative 'lib/pdex'

nppes_dir = 'sample-nppes-data'

managing_organization_filenames = File.join(nppes_dir, 'managing_orgs_data.csv')
organization_filenames = File.join(nppes_dir, 'sample-nppes-organization-data.csv')
practitioner_filenames = File.join(nppes_dir, 'sample-nppes-practitioner_20181204-data.csv')
network_filenames = File.join(nppes_dir, 'sample-nppes-network_20181204-data.csv')

plan_data = []
organization_data = []
practitioner_data = []
network_data = []
managing_org_data = []

networks = []
organizations = []
practitioners = []

FileUtils.mkdir_p('output/InsurancePlan')
FileUtils.mkdir_p('output/Organization')
CSV.foreach(managing_organization_filenames, headers: true) do |row|
  if row['is_plan'].downcase == 'true' && row['type'].downcase == 'ins'
    plan_data << nppes_data = PDEX::NPPESManagingOrg.new(row)
    resource = PDEX::InsurancePlanFactory.new(nppes_data).build
    File.write("output/InsurancePlan/#{resource.id}.json", resource.to_json)
  elsif row['type'].downcase == 'prov' && row['is_plan'].downcase == 'false'
    managing_org_data << nppes_data = PDEX::NPPESManagingOrg.new(row, managing_org: true)
    resource = PDEX::OrganizationFactory.new(nppes_data, managing_org: true).build
    File.write("output/Organization/#{resource.id}.json", resource.to_json)
  elsif row['type'].downcase == 'ins'
    nppes_data = PDEX::NPPESManagingOrg.new(row, payer: true)
    resource = PDEX::OrganizationFactory.new(nppes_data, payer: true).build
    File.write("output/Organization/#{resource.id}.json", resource.to_json)
  end
end

FileUtils.mkdir_p('output/Network')
CSV.foreach(network_filenames, headers: true) do |row|
  network_data << nppes_data = PDEX::NPPESNetwork.new(row)
  networks << resource = PDEX::NetworkFactory.new(nppes_data).build
  File.write("output/Network/#{resource.id}.json", resource.to_json)
end

network_data_by_state = network_data.group_by { |network| network.address.state }
organization_networks = {}
organization_service_resources = Hash.new { |hash, key| hash[key] = [] }
managing_org_data_by_state = managing_org_data.group_by { |org| org.address.state }

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

  organization_services = []
  PDEX::NUCCConstants::SERVICE_LIST.each do |service|
    resource = PDEX::HealthcareServiceFactory.new(nppes_data, service).build
    organization_services << resource
    File.write("output/HealthcareService/#{resource.id}.json", resource.to_json)
  end

  state = nppes_data.address.state
  state_networks = network_data_by_state[state]
  if state_networks.blank?
    state_networks = network_data_by_state['MA']
  end
  organization_networks[nppes_data.npi] = state_networks.sample(nppes_data.name.length % state_networks.length + 1)
  managing_orgs = managing_org_data_by_state[state]
  if managing_orgs.blank?
    managing_orgs = managing_org_data_by_state['MA']
  end
  managing_org = managing_orgs[nppes_data.name.length % managing_orgs.length]
  resource = PDEX::OrganizationAffiliationFactory.new(
    nppes_data,
    networks: organization_networks[nppes_data.npi],
    managing_org: managing_org,
    services: organization_services
  ).build
  File.write("output/OrganizationAffiliation/#{resource.id}.json", resource.to_json)
end

organization_data_by_state = organization_data.group_by { |org| org.address.state }

FileUtils.mkdir_p('output/Practitioner')
FileUtils.mkdir_p('output/PractitionerRole')
CSV.foreach(practitioner_filenames, headers: true) do |row|
  practitioner_data << nppes_data = PDEX::NPPESPractitioner.new(row)
  practitioners << resource = PDEX::PractitionerFactory.new(nppes_data).build
  File.write("output/Practitioner/#{resource.id}.json", resource.to_json)

  practitioner_state = nppes_data.address.state
  practitioner_state = 'MA' unless organization_data_by_state.keys.include? practitioner_state
  state_orgs = organization_data_by_state[practitioner_state]
  organization = state_orgs[nppes_data.npi.to_i % state_orgs.length]
  networks = organization_networks[organization.npi]
  resource = PDEX::PractitionerRoleFactory.new(nppes_data, organization: organization, networks: networks).build
  File.write("output/PractitionerRole/#{resource.id}.json", resource.to_json)
end

