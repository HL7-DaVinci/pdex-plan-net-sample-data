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
          specialty: specialty,
          participatingOrganization: organization,
          healthcareService: healthcareService,
          location: pharmacy_locations 
        }
      )
    end

    private

    def pharmacy_locations
      locations.map do |pharm_data|
        {
          reference: "Location/plannet-location-#{pharm_data.npi}",  
          display: pharm_data.name
        }
      end
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
                system: 'http://hl7.org/fhir/us/davinci-pdex-plan-net/CodeSystem/OrganizationAffiliationRoleCS',
                code: 'pharmacy',
                display: 'Pharmacy'
              }
            ],
            text: 'Pharmacy'
          }
        ]
      end
  

    def pharmacy_codes
      indexes = [0,1,2].push(3 + (source_data.name.length % 7))
      @codes ||= NUCCCodes.specialty_codes(HEALTHCARE_SERVICE_CATEGORY_TYPES[:pharmacy].downcase).select.with_index{ |_e, i| indexes.include?(i) }
  end

  def specialty
      pharmacy_codes.map do |code|
        display = NUCCCodes.specialty_display(code)
        {
          coding: [
            {
              code: code,
              system: 'http://nucc.org/provider-taxonomy',
              display: display
            }
          ],
          text: display
        }
      end
   end

  end
end