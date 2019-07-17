require 'fhir_models'
require_relative 'utils/states'
require_relative 'utils/nucc_codes'

# TODO:
# - identifier.period - is this really needed?
# - geolocation extension
# - partOf
# - endpoint
module PDEX
  class OrganizationFactory
    attr_reader :organization

    def initialize(nppes_organization)
      @organization = nppes_organization
    end

    def build
      FHIR::Organization.new(
        {
          id: id,
          meta: meta,
          identifier: identifier,
          active: true,
          type: type,
          name: name,
          telecom: telecom,
          address: address,
          contact: contact,
        }
      )
    end

    private

    def id
      "vhdir-organization-#{organization.npi}"
    end

    def meta
      {
        profile: [ORGANIZATION_PROFILE_URL]
      }
    end

    def identifier
      {
        use: 'official',
        type: {
          coding: [
            {
              system: 'http://terminology.hl7.org/CodeSystem/v2-0203',
              code: 'NPI',
              display: 'Provider number',
              userSelected: true
            }
          ],
          text: 'NPI'
        },
        system: 'http://hl7.org/fhir/sid/us-npi',
        value: organization.npi,
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
              system: 'http://terminology.hl7.org/CodeSystem/organization-type',
              code: 'prov',
              display: 'Healthcare Provider'
            }
          ],
          text: 'Healthcare Provider'
        }
      ]
    end

    def name
      organization.name
    end

    def telecom
      [
        {
          system: 'phone',
          value: organization.phone
        }
      ]
    end

    def address
      lines = organization.address.lines
      city = organization.address.city
      state = organization.address.state
      zip = organization.address.zip
      text = [lines, "#{city}, #{state} #{zip}"].flatten.join(', ')
      {
        use: 'work',
        type: 'both',
        text: text,
        line: lines,
        city: city,
        state: state,
        postalCode: zip,
        country: 'USA'
      }
    end

    def contact
      {
        purpose: {
          coding: [
            {
              system: 'http://terminology.hl7.org/CodeSystem/contactentity-type',
              code: 'ADMIN',
              display: 'Administrative'
            }
          ]
        },
        name: {
          use: 'official',
          text: "#{organization.contact_first_name} #{organization.contact_last_name}",
          family: organization.contact_last_name,
          given: [organization.contact_first_name]
        },
        telecom: [
          telecom.first.merge(
            {
              use: 'work',
              extension: [
                {
                  url: 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/contactpoint-availabletime',
                  extension:
                    ['mon', 'tue', 'wed', 'thu', 'fri']
                    .map { |day| { url: 'daysOfWeek', valueCode: day } }
                    .concat(
                      [
                        { url: 'availableStartTime', valueTime: '07:00:00' },
                        { url: 'availableEndTime', valueTime: '18:00:00' }
                      ]
                    )
                }
              ]
            }
          )
        ],
        address: address
      }
    end
  end
end
