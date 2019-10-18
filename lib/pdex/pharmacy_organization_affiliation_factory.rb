require 'fhir_models'
require 'securerandom'
require_relative 'address'
require_relative 'telecom'
require_relative 'utils/formatting'
require_relative 'utils/states'
require_relative 'utils/nucc_codes'

module PDEX
  class PharmacyOrganizationAffiliationFactory < OrganizationAffiliationFactory
    include Address
    include Telecom
    include Formatting

    attr_reader :source_data, :networks, :managing_org, :services

      def build
      FHIR::OrganizationAffiliation.new(
        {
          id: id,
          meta: meta,
          active: true,
          network: network,
          code: code,
          organization: organization,
          healthcareService: healthcareService
        }
      )
    end

    private

    def id
      "plannet-organizationaffiliation-#{source_data.npi}"
    end

    def organization
        {
          reference: "Organization/plannet-organization-#{source_data.npi}",
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
            text: 'Pharmacy Provider Member'
          }
        ]
      end
  
    end
end
