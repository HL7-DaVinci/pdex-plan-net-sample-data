require_relative './healthcare_service_factory'
require_relative './nppes_data_repo'
require_relative './organization_factory'
require_relative './organization_affiliation_factory'
require_relative './utils/nucc_constants'

module PDEX
  class OrganizationGenerator
    attr_reader :nppes_data

    def initialize(nppes_data, parent_organization: parent = nil )
      @nppes_data = nppes_data
      @parent = parent
    end

    def generate
      [organization, organization_affiliation].concat(organization_services)
    end

    private

    def organization
      PDEX::OrganizationFactory.new(nppes_data).build
    end

    def organization_affiliation
      PDEX::OrganizationAffiliationFactory.new(
        nppes_data,
        networks: networks,
        managing_org: managing_org,
        services: organization_services,
        locations: nil 
      ).build
    end

    def organization_services
      @organization_services ||=
        PDEX::NUCCConstants::SERVICE_LIST.map do |service|
          PDEX::HealthcareServiceFactory.new(nppes_data, service).build
        end
    end

    def state
      nppes_data.address.state
    end

    def state_networks
      PDEX::NPPESDataRepo.networks_by_state(state)
    end

    def networks
      @networks ||= state_networks.sample(nppes_data.name.length % state_networks.length + 1)
      PDEX::NPPESDataRepo.organization_networks[nppes_data.npi] = @networks
    end

    def state_managing_orgs
      PDEX::NPPESDataRepo.managing_orgs_by_state(state)
    end

    def managing_org
 
      state_managing_orgs[nppes_data.name.length % state_managing_orgs.length]

    end
  end
end
