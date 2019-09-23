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
      [practitioner, practitioner_role]
    end

    private

    def practitioner
      PDEX::PractitionerFactory.new(nppes_data).build
    end

    def practitioner_role
      PDEX::PractitionerRoleFactory.new(nppes_data, organization: organization, networks: networks).build
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

    def networks
      PDEX::NPPESDataRepo.organization_networks[organization.npi]
    end
  end
end
