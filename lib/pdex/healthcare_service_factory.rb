require_relative 'telecom'
require_relative 'fhir_elements'
require_relative 'utils/formatting'
require_relative 'utils/nucc_codes'
require_relative 'utils/randoms'

module PDEX
  class HealthcareServiceFactory
    include Formatting
    include FHIRElements
    include Telecom
    include ShortName
    include Randoms

    attr_reader :source_data, :locations_list, :provided_by, :category_type, :profile

    def initialize(nppes_data, locations: , provided_by: , category_type: )
      @source_data = nppes_data
      @locations_list = locations
      @provided_by = provided_by
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
            new_patients_extension,
            delivery_method_extension
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

    def category_type_display
      case category_type
      when 'behav'
        'Behavioral Health'
      when 'dent'
        'Dental'
      when 'dme'
        'DME/Medical Supplies'
      when 'emerg'
        'Emergency care'
      when 'group'
        'Medical Group'
      when 'home'
        'Home Health'
      when 'hosp'
        'Hospital'
      when 'lab'
        'Laboratory'
      when 'other'
        'Other'
      when 'outpat'
        'Clinic or Outpatient Facility'
      when 'prov'
        'Medical Provider'
      when 'pharm'
        'Pharmacy'
      when 'trans'
        'Transportation'
      when 'urg'
        'Urgent Care'
      when 'vis'
        'Vision'
      else
        category_type.capitalize
      end

    end

    def locations
      locations_list.map do |data|
        {
          reference: "Location/plannet-location-#{data.npi}",  
          display: data.name
        }
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
      if category_type.eql? HEALTHCARE_SERVICE_CATEGORY_TYPES[:pharmacy]
        specialities = pharmacy_codes.map do |code|
          NUCCCodes.specialty_display(code).strip
        end
        specialities.join('; ')
      elsif category_type.eql? HEALTHCARE_SERVICE_CATEGORY_TYPES[:provider]
        qualifications = source_data.qualifications.map do |qualification|
          NUCCCodes.specialty_display(qualification.taxonomy_code).strip
        end
        qualifications.join('; ')
      end
    end

    def pharmacy_codes
        indexes = [0,1,2].push(3 + (name.length % 7))
        @codes ||= NUCCCodes.specialty_codes(category_type.downcase).select.with_index{ |_e, i| indexes.include?(i) }
    end

    def specialty

      if category_type.eql? HEALTHCARE_SERVICE_CATEGORY_TYPES[:pharmacy]
        pharmacy_codes.map do |code|
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
      elsif category_type.eql? HEALTHCARE_SERVICE_CATEGORY_TYPES[:provider]
        source_data.qualifications
          .map { |qualification| nucc_codeable_concept(qualification) }
          .first
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
                  code: accepting_patients_code(name.length)
                }
              ]
            }
          }
        ]
      }
    end

    def delivery_method_extension
      {
        url: DELIVERY_METHOD_EXTENSION_URL,
        extension: [
          {
            url: DELIVERY_METHOD_TYPE_EXTENSION_URL,
            valueCodeableConcept: {
              coding: [
                {
                  system: DELIVERY_METHOD_CODE_SYSTEM_URL,
                  code: "physical",
                  display: "Physical"
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
