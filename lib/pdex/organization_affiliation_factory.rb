require 'fhir_models'
require 'securerandom'
require_relative 'address'
require_relative 'telecom'
require_relative 'utils/formatting'
require_relative 'utils/states'
require_relative 'utils/nucc_codes'

module PDEX
  class OrganizationAffiliationFactory
    include Address
    include Telecom
    include Formatting

    attr_reader :source_data, :networks, :managing_org, :services, :locations

    def initialize(nppes_organization, networks:, managing_org:, services:, locations: nil)
      @source_data = nppes_organization
      @networks = networks
      @managing_org = managing_org
      @services = services
      @locations = locations 
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
          network: network,
          healthcareService: healthcareService
        }
      )
    end

    private

    def id
      "plannet-organizationaffiliation-#{source_data.npi}"
    end

    def meta
      {
        profile: [ORGANIZATION_AFFILIATION_PROFILE_URL],
        lastUpdated: '2020-08-17T10:03:10Z'
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
          display: managing_org.name
        }
      }
    end

    def part_of_id
      "plannet-organization-#{managing_org.part_of_id}"
    end

    def organization
      {
        reference: "Organization/plannet-organization-#{managing_org.npi}",
        display: managing_org.name
      }
    end

    def participatingOrganization
      {
        reference: "Organization/plannet-organization-#{source_data.npi}",
        display: source_data.name
      }
    end

    def network
      networks.map do |network_data|
        {
          reference: "Organization/plannet-network-#{network_data.npi}",
          display: network_data.name
        }
      end
    end

    def healthcareService
      services.map do |service|
        {
          reference: "HealthcareService/#{service.id}",
          display: service.category.first.text
        }
      end
    end
  end
end
