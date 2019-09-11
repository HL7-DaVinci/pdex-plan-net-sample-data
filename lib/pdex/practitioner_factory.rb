require 'date'
require 'fhir_models'
require_relative 'address'
require_relative 'fhir_elements'
require_relative 'telecom'
require_relative 'utils/states'
require_relative 'utils/nucc_codes'

module PDEX
  class PractitionerFactory
    include Address
    include FHIRElements
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
          address: address_with_geolocation,
          gender: gender,
          qualification: qualifications,
          communication: communication
        }
      )
    end

    private

    def id
      "plannet-practitioner-#{source_data.npi}"
    end

    def meta
      {
        profile: [PRACTITIONER_PROFILE_URL],
        versionId: '1'
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
      end.compact
    end

    def format_date_time(date_time)
      date_time.strftime('%Y-%m-%d')
    end

    def three_year_period
      end_date = DateTime.now + rand() * (365 * 3)
      start_month = end_date.month
      start_day = start_month == 2 && end_date.day == 29 ? 28 : end_date.day
      start_year = end_date.year - 3
      start_date = DateTime.new(start_year, start_month, start_day)
      {
        start: format_date_time(start_date),
        end: format_date_time(end_date)
      }
    end

    def qualification(data)
      state_display = States.display_name(data.state)
      licensor = States.licensor(data.state.to_sym)
      licensor_system = States.licensor_system(data.state)
      return nil if licensor.blank?

      {
        extension: [
          {
            url: PRACTITIONER_QUALIFICATION_EXTENSION_URL,
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
              coding: [
                {
                  code: 'MD',
                  system: 'http://terminology.hl7.org/CodeSystem/v2-0203',
                  display: 'Medical License Number'
                }
              ],
              text: 'Medical License Number'
            },
            system: licensor_system,
            value: data.license_number,
            assigner: {
              display: licensor
            }
          }
        ],
        period: three_year_period,
        code: nucc_codeable_concept(data),
        issuer: {
          display: licensor
        }
      }
    end

    def communication
      english = {
        coding: [
          {
            system: 'urn:ietf:bcp:47',
            code: 'en',
            display: 'English'
          }
        ],
        text: 'English',
        extension: proficiency_extension(true)
      }
      [
        english,
        second_language((source_data.name.first + source_data.name.last).length % 10)
      ].compact
    end

    def second_language(n)
      language = [
        {
          code: 'ht',
          display: 'Haitian Creole'
        },
        {
          code: 'zh',
          display: 'Chinese'
        },
        {
          code: 'es',
          display: 'Spanish'
        },
        {
          code: 'pt',
          display: 'Portuguese'
        },
        {
          code: 'vi',
          display: 'Vietnamese'
        }
      ][n]

      return if language.blank?

      {
        coding: [
          {
            system: 'urn:ietf:bcp:47',
            code: language[:code],
            display: language[:display]
          }
        ],
        text: language[:display],
        extension: [proficiency_extension]
      }
    end

    PROFICIENCIES = [
      {
        code: '06',
        display: 'Memorized proficiency'
      },
      {
        code: '10',
        display: 'Elementary proficiency'
      },
      {
        code: '20',
        display: 'Limited working proficiency'
      },
      {
        code: '30',
        display: 'General professional proficiency'
      },
      {
        code: '40',
        display: 'Advanced professional proficiency'
      },
      {
        code: '50',
        display: 'Functional native proficiency'
      }
    ]

    def proficiency_extension(fluent = false)
      proficiency =
        if fluent
          PROFICIENCIES.last
        else
          PROFICIENCIES[address[:text].length % PROFICIENCIES.length]
        end

      {
        url: PDEX::COMMUNICATION_PROFICIENCY_EXTENSION_URL,
        valueCodeableConcept: {
          coding: [
            proficiency.merge({ system: PDEX::COMMUNICATION_PROFICIENCY_SYSTEM_URL})
          ],
          text: proficiency[:display]
        }
      }
    end
  end
end
