require 'csv'
require 'pry'
require_relative 'lib/pdex'

networks = []
organizations = []
practitioners = []

PDEX::NPPESDataLoader.load

FileUtils.mkdir_p('output/InsurancePlan')
PDEX::NPPESDataRepo.plans.each do |nppes_data|
  resource = PDEX::InsurancePlanFactory.new(nppes_data).build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)
end

FileUtils.mkdir_p('output/Organization')
PDEX::NPPESDataRepo.managing_orgs.each do |nppes_data|
  resource = PDEX::OrganizationFactory.new(nppes_data, managing_org: true).build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)
end

PDEX::NPPESDataRepo.payers.each do |nppes_data|
  resource = PDEX::OrganizationFactory.new(nppes_data, payer: true).build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)
end

PDEX::NPPESDataRepo.networks.each do |nppes_data|
  networks << resource = PDEX::NetworkFactory.new(nppes_data).build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)
end

network_data_by_state = PDEX::NPPESDataRepo.networks.group_by { |network| network.address.state }
organization_networks = {}
managing_org_data_by_state = PDEX::NPPESDataRepo.managing_orgs.group_by { |org| org.address.state }

FileUtils.mkdir_p('output/OrganizationAffiliation')
FileUtils.mkdir_p('output/Location')
FileUtils.mkdir_p('output/Endpoint')
FileUtils.mkdir_p('output/HealthcareService')
PDEX::NPPESDataRepo.organizations.each do |nppes_data|
  organizations << resource = PDEX::OrganizationFactory.new(nppes_data).build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)

  resource = PDEX::LocationFactory.new(nppes_data).build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)

  resource = PDEX::EndpointFactory.new(nppes_data, 'Organization').build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)

  organization_services = []
  PDEX::NUCCConstants::SERVICE_LIST.each do |service|
    resource = PDEX::HealthcareServiceFactory.new(nppes_data, service).build
    organization_services << resource
    File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)
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
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)
end

organization_data_by_state = PDEX::NPPESDataRepo.organizations.group_by { |org| org.address.state }

FileUtils.mkdir_p('output/Practitioner')
FileUtils.mkdir_p('output/PractitionerRole')
PDEX::NPPESDataRepo.practitioners.each do |nppes_data|
  practitioners << resource = PDEX::PractitionerFactory.new(nppes_data).build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)

  practitioner_state = nppes_data.address.state
  practitioner_state = 'MA' unless organization_data_by_state.keys.include? practitioner_state
  state_orgs = organization_data_by_state[practitioner_state]
  organization = state_orgs[nppes_data.npi.to_i % state_orgs.length]
  networks = organization_networks[organization.npi]
  resource = PDEX::PractitionerRoleFactory.new(nppes_data, organization: organization, networks: networks).build
  File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)
end

