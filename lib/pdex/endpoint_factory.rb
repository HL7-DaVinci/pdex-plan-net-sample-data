require_relative 'utils/formatting'

module PDEX
  class EndpointFactory
    include Formatting

    attr_reader :source_data, :source_type, :profile

    def initialize(source_data, source_type)
      @source_data = source_data
      @source_type = source_type.downcase
      @profile = ENDPOINT_PROFILE_URL
    end

    def build
      FHIR::Endpoint.new(
        {
          id: id,
          meta: meta,
          status: 'active',
          connectionType: connection_type,
          name: name,
          managingOrganization: managing_organization,
          contact: contact,
          payloadType: payload_type,
          address: address,
          extension: [
            use_case_extension
          ]
        }
      )
    end

    private

    def id
      "plannet-#{source_type}-#{source_data.npi}-direct"
    end

    def meta
      {
        profile: [profile],
        lastUpdated: '2020-08-17T10:03:10Z'
      }
    end

    def connection_type
      {
        code: 'direct-project',
        system: 'http://terminology.hl7.org/CodeSystem/endpoint-connection-type',
        display: 'Direct Project'
      }
    end

    def name
      "#{source_data.name} Direct Address"
    end

    def managing_organization
      {
        reference: "Organization/plannet-organization-#{source_data.npi}",
        display: source_data.name
      }
    end

    def contact
      source_data.phone_numbers.map do |number|
        {
          system: 'phone',
          value: number
        }
      end
    end

    def payload_type
      [
        {
          coding: [
            {
              system: ENDPOINT_PAYLOAD_TYPE_SYSTEM_URL,
              code: 'NA',
              display: 'Not Applicable'
            }
          ]
        }
      ]
    end



    def address
      name_slug = format_for_url(source_data.name)
      "mailto:#{name_slug}@direct.#{name_slug}.org"
    end

    def use_case_extension
      {
        url: ENDPOINT_USE_CASE_EXTENSION_URL,
        extension: [
          {
            url: 'Type',
            valueCodeableConcept: {
              coding: [
                {
                  system: ENDPOINT_USE_CASE_SYSTEM_URL,
                  code: 'TREAT',
                  display: 'treatment'
                }
              ]
            }
          },
          {
            url: 'Standard',
            valueUri: 'http://wiki.directproject.org/File:2011-03-09_PDF_-_XDR_and_XDM_for_Direct_Messaging_Specification_FINAL.pdf'
          }
        ]
      }
    end
  end
end
