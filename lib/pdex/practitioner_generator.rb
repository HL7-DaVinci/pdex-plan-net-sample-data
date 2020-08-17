require_relative './nppes_data_repo'
require_relative './practitioner_factory'
require_relative './practitioner_role_factory'

module PDEX
  class PractitionerGenerator
    attr_reader :nppes_data

    def initialize(nppes_data)
      @nppes_data = nppes_data
    end

    def generate
      [practitioner, practitioner_role].concat(practioner_services)
    end

    private

    def practitioner
      PDEX::PractitionerFactory.new(nppes_data).build
    end

    def practitioner_role
      PDEX::PractitionerRoleFactory.new(nppes_data, organization: organization, networks: networks, services: services_ref).build
    end

    def practioner_services
      @practioner_services ||= [ PDEX::HealthcareServiceFactory.new(nppes_data, [organization], organization_ref, HEALTHCARE_SERVICE_CATEGORY_TYPES[:provider]).build ]
    end

    def state
      nppes_data.address.state
    end

    def organizations
      PDEX::NPPESDataRepo.organizations_by_state(state)
    end

    def organization
      organizations[nppes_data.npi.to_i % organizations.length]
    end

    def organization_ref
      {
        reference: "Organization/plannet-organization-#{organization.npi}",
        display: organization.name
      }
    end

    def services_ref
      practioner_services.map do |service|
        {
          reference: "HealthcareService/#{service.id}",
          display: service.category.first.text
        }
      end
    end

    def networks
      PDEX::NPPESDataRepo.organization_networks[organization.npi]
    end
  end
end
