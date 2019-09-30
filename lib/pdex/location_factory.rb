require 'fhir_models'
require_relative 'address'
require_relative 'telecom'
require_relative 'utils/formatting'

module PDEX
  class LocationFactory
    include Address
    include Telecom
    include Formatting

    attr_reader :source_data, :pharmacy

    def initialize(nppes_data, pharmacy: false)
      @source_data = nppes_data
      @pharmacy = pharmacy
    end

    def build
      FHIR::Location.new(
        {
          id: id,
          meta: meta,
          extension: [
            accessibility_extension,
            new_patients_extension,
            new_patient_profile_extension
          ],
          identifier: identifier,
          status: 'active',
          name: name,
          description: description,
          type: type,
          telecom: telecom,
          address: address,
          position: position,
          managingOrganization: managing_organization,
          hoursOfOperation: hours_of_operation,
          availabilityExceptions: availability_exceptions
        }
      )
    end

    private

    def id
      "plannet-location-#{source_data.npi}"
    end

    def organization_id
      "plannet-organization-#{source_data.npi}"
    end

    def meta
      {
        profile: [LOCATION_PROFILE_URL],
      }
    end

    def accessibility_extension
      {
        url: ACCESSIBILITY_EXTENSION_URL,
        valueCodeableConcept: {
          coding: [
            {
              system: ACCESSIBILITY_CODE_SYSTEM_URL,
              code: 'handiaccess',
              display: 'handicap accessible'
            }
          ],
          text: 'Offers a variety of services and programs for persons with disabilities'
        }
      }
    end

    def new_patients_extension
      {
        url: NEW_PATIENTS_EXTENSION_URL,
        extension: [
          {
            url: 'acceptingPatients',
            valueBoolean: name.length.odd?
          }
        ]
      }
    end

    def new_patient_profile_extension
      {
        url: NEW_PATIENT_PROFILE_EXTENSION_URL,
        valueString: 'This location accepts all types of patients'
      }
    end

    def identifier
      {
        use: 'secondary',
        system: "https://#{format_for_url(source_data.name)}.com",
        value: 'main campus',
        assigner: {
          reference: "Organization/#{organization_id}",
          display: source_data.name
        }
      }
    end

    def name
      source_data.name
    end

    def description
      "Main campus of #{name}"
    end

    def type
      return unless pharmacy
      [
        {
          coding: [
            {
              system: 'http://terminology.hl7.org/CodeSystem/v3-RoleCode',
              code: 'OUTPHARM'
            }
          ],
          text: 'Outpatient pharmacy'
        }
      ]
    end

    def telecom
      super.map do |telecom_entry|
        telecom_entry.merge(
          {
            extension: [
              {
                url: CONTACT_POINT_AVAILABLE_TIME_EXTENSION_URL,
                extension: [
                  {
                    url: 'allDay',
                    valueBoolean: true
                  }
                ]
              }
            ]
          }
        )
      end
    end

    def managing_organization
      {
        reference: "Organization/#{organization_id}",
        display: name
      }
    end

    def hours_of_operation
      [
        {
          daysOfWeek: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
          allDay: true
        }
      ]
    end

    def availability_exceptions
      'visiting hours from 6:00 am - 10:00 pm'
    end

    def position
      source_data.position
    end
  end
end
