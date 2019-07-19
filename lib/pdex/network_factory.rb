require_relative 'organization_factory'

module PDEX
  class NetworkFactory < OrganizationFactory
    def initialize(nppes_network)
      super
      @resource_type = 'network'
      @profile = NETWORK_PROFILE_URL
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
              system: 'http://terminology.hl7.org/CodeSystem/network-type',
              code: source_data.type[:code],
              display: source_data.type[:display]
            }
          ],
          text: source_data.type[:text]
        }
      ]
    end
  end
end
