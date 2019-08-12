require 'fhir_models'
require 'securerandom'
require_relative 'address'
require_relative 'telecom'
require_relative 'utils/states'
require_relative 'utils/nucc_codes'

module PDEX
  class OrganizationAffiliationFactory
    include Address
    include Telecom
    include Formatting

    attr_reader :source_data, :network

    def initialize(nppes_organization, network:)
      @source_data = nppes_organization
      @network = network
    end

    def build
      FHIR::OrganizationAffiliation.new(
        {
          id: id,
          meta: meta,
          identifier: identifier,
          active: true,
          organization: organization,
          participatingOrganization: participatingOrganization,
          code: code
        }
      )
    end

    private

    def id
      "vhdir-organizationaffiliation-#{source_data.npi}"
    end

    def meta
      {
        profile: [ORGANIZATION_AFFILIATION_PROFILE_URL]
      }
    end

    def identifier
      {
        use: 'secondary',
        type: {
          coding: [
            {
              system: 'http://terminology.hl7.org/CodeSystem/v2-0203',
              code: 'PRN',
              display: 'Provider number',
            }
          ],
          text: 'Network Provider ID'
        },
        system: "https://#{format_for_url(part_of_id)}.com",
        value: SecureRandom.hex(7),
        assigner: {
          display: network.part_of_name
        }
      }
    end

    def part_of_id
      "vhdir-organization-#{network.part_of_id}"
    end

    def organization
      {
        reference: "Organization/vhdir-organization-#{network.npi}",
        display: network.name
      }
    end

    def participatingOrganization
      {
        reference: "Organization/vhdir-organization-#{source_data.npi}",
        display: source_data.name
      }
    end

    def code
      [
        {
          coding: [
            {
              system: 'http://hl7.org/fhir/organization-role',
              code: 'member',
              display: 'Member'
            }
          ],
          text: 'Hospital Provider Member'
        }
      ]
    end
  end
end
