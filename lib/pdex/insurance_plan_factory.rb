# frozen_string_literal: true

require 'fhir_models'
require_relative 'utils/formatting'

module PDEX
  class InsurancePlanFactory
    include Formatting

    attr_reader :source_data, :resource_type, :profile

    def initialize(nppes_organization)
      @source_data = nppes_organization
      @resource_type = 'insuranceplan'
      @profile = INSURANCE_PLAN_PROFILE_URL
    end

    def build
      FHIR::InsurancePlan.new(
        id: id,
        meta: meta,
        identifier: identifier,
        status: 'active',
        type: type,
        name: name,
        alias: plan_alias,
        ownedBy: owned_by,
        administeredBy: administered_by,
        network: network
        # coverage: coverage,    ** Coverage is 0..* in plan-net
      )
    end

    private

    def id
      "plannet-#{resource_type}-#{source_data.id}"
    end

    def meta
      {
        profile: [profile],
        lastUpdated: '2020-08-17T10:03:10Z'
      }
    end

    def identifier
      {
        use: 'official',
        type: {
          coding: [
            {
              system: "http://terminology.hl7.org/CodeSystem/v2-0203",
              code: "NIIP",
              display: "National Insurance Payor Identifier (Payor)"
            }
          ],
          text: 'HIOS product ID'
        },
        system: 'http://www.cms.gov/CCIIO',
        value: source_data.id,
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
              system: INSURANCE_PLAN_TYPE_CODE_SYSTEM_URL,
              code: "commppo",
              display: "Commercial PPO"
            }
          ],
          text: "Health insurance provided through a Preferred Provider Organization (PPO)"
        }
      ]
    end

    def name
      source_data.name
    end

    def plan_alias
      source_data.alias
    end

    def period
      {
        start: '2019-01-01',
        end: '2020-01-01'
      }
    end

    def network
      [
        {
          reference: "Organization/plannet-network-#{source_data.network_id}",
          display: source_data.network_name

        }
      ]
    end

    def owned_by
      {
        reference: "Organization/plannet-organization-#{source_data.owner_id}",
        display: source_data.owner_name
      }
    end

    def administered_by
      {
        reference: "Organization/plannet-organization-#{source_data.administrator_id}",
        display: source_data.administrator_name
      }
    end

    # coverage is 0..0 in plan-net
    #   def coverage
    #     {
    #       coverage: [
    #         {
    #           type: {
    #             coding: [
    #               {
    #                 code: 'medical',
    #                 display: 'Medical'
    #               }
    #             ],
    #             text: 'Coverage related to medical inpatient, outpatient, diagnostic, and preventive care'
    #           },
    #           network: [
    #             {
    #               reference: "Organization/plannet-organization-#{source_data.network_id}",
    #               display: source_data.network_name
    #             }
    #           ],
    #           benefit: [
    #             {
    #               type: {
    #                 coding: [
    #                   {
    #                     code: 'prev',
    #                     system: PAYER_CHARACTERISTICS_CODE_SYSTEM_URL,
    #                     display: 'Preventive Care/Screening/Immunization',
    #                   }
    #                 ],
    #                 text: 'Routine healthcare services to prevent health related problems eligible benefits.'
    #               },
    #               requirement: 'N/A',
    #               limit: [
    #                 {
    #                   value: {
    #                     value: 1,
    #                     unit: 'visit/year',
    #                   },
    #                   code: {
    #                     coding: [
    #                       {
    #                         code: 'visitsperyr',
    #                         system: PAYER_CHARACTERISTICS_CODE_SYSTEM_URL,
    #                         display: 'Visits per year'
    #                       }
    #                     ],
    #                     text: 'Measure of service covered by the plan benefit expressed in a definite number of visits covered per year.'
    #                   }
    #                 }
    #               ]
    #             },
    #             {
    #               type: {
    #                 coding: [
    #                   {
    #                     code: 'pcpov',
    #                     system: PAYER_CHARACTERISTICS_CODE_SYSTEM_URL,
    #                     display: 'Primary care visit to treat an injury or illness'
    #                   }
    #                 ]
    #               },
    #               requirement: 'N/A',
    #               limit: [
    #                 {
    #                   value: {
    #                   },
    #                   code: {
    #                     coding: [
    #                       {
    #                         code: 'visit',
    #                         display: 'Visits',
    #                       }
    #                     ],
    #                     text: 'Measure of service covered by the plan benefit expressed in a definite number of visits.'
    #                   }
    #                 }
    #               ]
    #             }
    #           ]
    #         }
    #       ]
    #     }
    #   end
  end
end
