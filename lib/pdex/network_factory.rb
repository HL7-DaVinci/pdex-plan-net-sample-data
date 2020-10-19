require_relative 'organization_factory'

module PDEX
  class NetworkFactory < OrganizationFactory
    def initialize(nppes_network)
      super
      @resource_type = 'network'
      @profile = NETWORK_PROFILE_URL
    end

    private

    def build_params
      super.tap do |params|
        params.merge!(partOf: part_of, address: address)
        params.delete(:telecom)
      end
    end

    def identifier
      {
        use: 'official',
        type: {
          coding: [
            {
              system: 'http://terminology.hl7.org/CodeSystem/v2-0203',
              code: 'NIIP',
              display: 'National Insurance Payor Identifier (Payor)',
              userSelected: true
            }
          ],
          text: 'The Health Plan Identifier (HPID)'
        },
        system: 'https://www.qhpcertification.cms.gov/s/QHP',
        value: source_data.npi,
        assigner: {
          display: 'Centers for Medicare and Medicaid Services'
        }
      }
    end

    def type
      [
        {
          coding: [
            {
              system: ORGANIZATION_TYPE_SYSTEM_URL,
              code: 'ntwk',
              display: 'Network'
            }
          ],
          text: 'A healthcare provider insurance network'
        }
      ]
    end

    def part_of
      {
        reference: "Organization/plannet-organization-#{source_data.part_of_id}",
        display: source_data.part_of_name
      }
    end
  end
end
