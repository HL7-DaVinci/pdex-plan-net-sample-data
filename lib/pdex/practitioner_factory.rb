require 'fhir_models'
require_relative 'utils/states'
require_relative 'utils/nucc_codes'

module PDEX
  class PractitionerFactory
    attr_reader :practitioner

    def initialize(nppes_practitioner)
      @practitioner = nppes_practitioner
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
          # TODO: communication
        }
      )
    end

    private

    def id
      "vhdir-practitioner-#{practitioner.npi}"
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
        value: practitioner.npi,
        assigner: {
          display: 'CMS'
        }
      }
    end

    def name
      given_names = [practitioner.name.first, practitioner.name.middle].reject(&:blank?)
      family_name = practitioner.name.last
      prefix = practitioner.name.prefix
      suffix = [practitioner.name.suffix, practitioner.name.credential].reject(&:blank?)
      {
        use: 'official',
        family: family_name,
        given: given_names
      }.tap do |human_name|
        human_name[:prefix] = prefix if prefix.present?
        human_name[:suffix] = suffix if suffix.present?
      end
    end

    def telecom
      phone_entries = practitioner.phone_numbers.map { |phone| telecom_entry('phone', phone) }
      fax_entries = practitioner.fax_numbers.map { |fax| telecom_entry('fax', fax) }
      phone_entries + fax_entries
    end

    def telecom_entry(type, number)
      {
        system: type,
        value: number,
        use: 'work'
      }
    end

    def address
      lines = practitioner.address.lines
      city = practitioner.address.city
      state = practitioner.address.state
      zip = practitioner.address.zip
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

    def gender
      {
        'F' => 'female',
        'M' => 'male',
      }[practitioner.gender]
    end

    def qualifications
      practitioner.qualifications.map do |qualification_data|
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
