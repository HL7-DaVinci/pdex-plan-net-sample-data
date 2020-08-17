require_relative 'telecom'
require_relative 'utils/formatting'
require_relative 'utils/nucc_codes'

module PDEX
  class HealthcareServiceFactory
    include Formatting
    include Telecom
    include ShortName

    attr_reader :source_data, :category_type, :profile

    def initialize(nppes_organization, category_type)
      @source_data = nppes_organization
      @category_type = category_type
      @profile = HEALTHCARE_SERVICE_PROFILE_URL
    end

    def build
      FHIR::HealthcareService.new(
        {
          id: id,
          meta: meta,
          active: true,
          category: category,
          providedBy: provided_by,
          specialty: specialty,
          location: locations,
          name: name,
          comment: comment,
          appointmentRequired: true,
          telecom: telecom,
          availableTime: available_time,
          extension: [
            new_patients_extension
          ]
        }
      )
    end

    private

    def id
      "#{format_for_url(category_type)[0..30]}-healthcareservice-#{source_data.npi}"
    end

    def meta
      {
        profile: [profile],
        lastUpdated: '2020-08-17T10:03:10Z'
      }
    end

    def identifier_system
      "http://#{format_for_url(source_data.name)}"
    end

    def provided_by
      {
        reference: "Organization/plannet-organization-#{source_data.npi}",
        display: source_data.name
      }
    end

    def category_type_display
      category_type.capitalize
    end

    def pharmacies_by_organization(organization)
      @pharmacy_by_organization ||= PDEX::NPPESDataRepo.pharmacies.group_by { |pharm| short_name(pharm.name) }
      if @pharmacy_by_organization[organization.name].length > 1
        puts "#{organization.npi}: #{@pharmacy_by_organization[organization.name].length}"
      end
      @pharmacy_by_organization[organization.name] 
    end

    def locations
      if category_type.eql? HEALTHCARE_SERVICE_CATEGORY_TYPES[:pharmacy]
        pharmacies_by_organization(source_data).map do |pharm_data|
          {
            reference: "Location/plannet-location-#{pharm_data.npi}",  
            display: pharm_data.name
          }
        end
      else 
        [
          {
            reference: "Location/plannet-location-#{source_data.npi}",
            display: source_data.name
          }
        ]
      end
    end

    def name
      source_data.name
    end

    def service_provision_code
      [
        {
          coding: [
            {
              code: 'cost',
              system: 'http://terminology.hl7.org/CodeSystem/service-provision-conditions',
              display: 'Fees apply'
            }
          ]
        }
      ]
    end

    def referral_method
      [
        {
          coding: [
            {
              code: 'phone',
              system: 'http://terminology.hl7.org/CodeSystem/service-referral-method',
              display: 'phone'
            }
          ]
        },
        {
          coding: [
            {
              code: 'fax',
              system: 'http://terminology.hl7.org/CodeSystem/service-referral-method',
              display: 'fax'
            }
          ]
        }
      ]
    end

    def available_time
      [
        {
          daysOfWeek: ['mon', 'tue', 'wed', 'thu', 'fri'],
          allDay: false,
          availableStartTime: '08:00:00',
          availableEndTime: '18:00:00'
        }
      ]
    end

    def comment
      NUCCCodes.specialties_display(category_type.downcase).strip
    end

    def specialty
      NUCCCodes.specialty_codes(category_type.downcase).map do |code|
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

    def new_patients_extension
      {
        url: NEW_PATIENTS_EXTENSION_URL,
        extension: [
          {
            url: ACCEPTING_NEW_PATIENTS_EXTENSION_URL,
            valueCodeableConcept: {
              coding: [
                {
                  system: ACCEPTING_PATIENTS_CODE_SYSTEM_URL,
                  code: name.length.odd? ? "yes" : "no"
                }
              ]
            }
          }
        ]
      }
    end

    def category
      {
        coding: [
          {
            system: HEALTHCARE_SERVICE_CATEGORY_CODE_SYSTEM_URL,
            code: category_type,
            display: category_type_display
          }
        ],
        text: category_type
      } 
    end
  end
end
