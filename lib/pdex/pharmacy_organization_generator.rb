require_relative './healthcare_service_factory'
require_relative './nppes_data_repo'
require_relative './organization_factory'
require_relative './pharmacy_organization_affiliation_factory'
require_relative './utils/nucc_constants'

module PDEX
  class PharmacyOrganizationGenerator < OrganizationGenerator

    def generate
      [organization, organization_affiliation].concat(organization_services)
    end

    private

    # Currently we only hav pharmacy data for CT
    def state
      'CT'
    end

    # call with pharmacy flag, or call pharmacy_org_data with appropriate arguments
    def organization
      PDEX::OrganizationFactory.new(nppes_data).build
    end

    def organization_affiliation
      PDEX::PharmacyOrganizationAffiliationFactory.new(
        nppes_data,
        networks: networks,
        services: organization_services,
        managing_org: nil
      ).build
    end

   # Add a single service -- pharmacy...
    def organization_services
      @organization_services ||= [ PDEX::HealthcareServiceFactory.new(nppes_data, "pharmacy").build ]
    end
  end
end
