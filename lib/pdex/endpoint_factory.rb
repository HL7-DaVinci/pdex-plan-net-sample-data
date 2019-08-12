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
          payloadMimeType: payload_mime_type,
          address: address,
        }
      )
    end

    private

    def id
      "vhdir-#{source_type}-#{source_data.npi}-direct"
    end

    def meta
      {
        profile: [profile]
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
        reference: "Organization/vhdir-organization-#{source_data.npi}",
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
              system: 'urn:oid:1.3.6.1.4.1.19376.1.2.3',
              code: 'urn:ihe:pcc:xphr:2007',
              display: 'HL7 CCD Document'
            }
          ]
        }
      ]
    end

    def payload_mime_type
      ['application/hl7-v3+xml']
    end

    def address
      name_slug = format_for_url(source_data.name)
      "mailto:#{name_slug}@direct.#{name_slug}.org"
    end
  end
end
