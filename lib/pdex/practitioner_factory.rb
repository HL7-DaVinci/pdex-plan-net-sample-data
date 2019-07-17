require 'fhir_models'
require_relative 'address'
require_relative 'telecom'
require_relative 'utils/states'
require_relative 'utils/nucc_codes'

# TODO:
# - communication - is this really needed?
# - geolocation extension
# - birthDate - is this really needed?

module PDEX
  class PractitionerFactory
    include Address
    include Telecom

    attr_reader :source_data

    def initialize(nppes_practitioner)
      @source_data = nppes_practitioner
    end

    def build
      FHIR::Practitioner.new(
        {
          id: id,
          meta: meta,
          identifier: identifier,
          active: true,
          name: name,
          telecom: telecom,
          address: address,
          gender: gender,
          qualification: qualifications
        }
      )
    end

    private

    def id
      "vhdir-practitioner-#{source_data.npi}"
    end

    def meta
      {
        profile: [PRACTITIONER_PROFILE_URL],
        versionId: 1
      }
    end

    def identifier
      {
        use: 'official',
        type: {
          coding: [
            {
              system: 'http://terminology.hl7.org/CodeSystem/v2-0203',
              code: 'PRN',
              display: 'Provider number',
              userSelected: true
            }
          ],
          text: 'NPI'
        },
        system: 'http://hl7.org/fhir/sid/us-npi',
        value: source_data.npi,
        assigner: {
          display: 'CMS'
        }
      }
    end

    def name
      given_names = [source_data.name.first, source_data.name.middle].reject(&:blank?)
      family_name = source_data.name.last
      prefix = source_data.name.prefix
      suffix = [source_data.name.suffix, source_data.name.credential].reject(&:blank?)
      {
        use: 'official',
        family: family_name,
        given: given_names
      }.tap do |human_name|
        human_name[:prefix] = prefix if prefix.present?
        human_name[:suffix] = suffix if suffix.present?
      end
    end

    def gender
      {
        'F' => 'female',
        'M' => 'male',
      }[source_data.gender]
    end

    def qualifications
      source_data.qualifications.map do |qualification_data|
        qualification(qualification_data)
      end
    end

    def qualification(data)
      state_display = States.display_name(data.state)
      licensor = States.licensor(data.state)
      licensor_system = States.licensor_system(data.state)
      qualification_display = NUCCCodes.display(data.taxonomy_code)
      {
        extension: [
          {
            url: 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/practitioner-qualification',
            extension: [
              {
                url: 'status',
                valueCoding: {
	                system: 'http://hl7.org/fhir/resource-status',
	                code: 'active',
	                display: 'active'
                }
              },
              {
                url: 'whereValid',
                valueCodeableConcept: {
                  coding: [
                    {
                      system: 'https://www.usps.com',
                      code: data.state,
                      display: state_display,
                      userSelected: true
                    }
                  ],
                  text: state_display
                }
              }
            ]
          }
        ],
        identifier: [
          {
            use: 'official',
            type: {
              text: 'Medical License Number'
            },
            system: licensor_system,
            value: data.license_number,
            period: {
              start: '2018-06-19',
              end: '2021-06-19'
            },
            assigner: {
              display: licensor
            }
          }
        ],
        code: {
          coding: [
            {
              system: 'http://nucc.org/provider-taxonomy',
              code: data.taxonomy_code,
              display: qualification_display,
              userSelected: true
            }
          ],
          text: qualification_display
        },
        issuer: {
          display: licensor
        }
      }
    end
  end
end
