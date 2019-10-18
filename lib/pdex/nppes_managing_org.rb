require_relative 'utils/fakes'
require_relative 'utils/formatting'
require_relative 'utils/position'

module PDEX
  class NPPESManagingOrg
    include Fakes
    include Formatting
    include Position

    PLAN_TYPE_DISPLAY = {
      cat: 'Catastrophic',
      bronze: 'Bronze',
      bronzeexp: 'Expanded Bronze',
      silver: 'Silver',
      gold: 'Gold',
      platinum: 'Platinum',
      lowded: 'Low deductible',
      highded: 'High deductible'
    }.freeze

    attr_reader :raw_data, :payer, :managing_org

    def initialize(raw_data, payer: false, managing_org: false)
      @raw_data = raw_data.freeze
      @payer = payer
      @managing_org = managing_org
    end

    def npi
      id
    end

    def id
      payer || managing_org ? fake_npi(raw_data['id']) : raw_data['plan_id']
    end

    def type
      raw_data['plan_type']
    end

    def type_display
      PLAN_TYPE_DISPLAY.fetch(type.to_sym)
    end

    def name
      managing_org || payer ? raw_data['name'] : raw_data['plan_name']
    end

    def alias
      raw_data['plan_alias']
    end

    def owner_id
      fake_npi(raw_data['partof_id'])
    end

    def owner_name
      raw_data['name'].split(' of').first
    end

    def administrator_id
      owner_id
    end

    def administrator_name
      owner_name
    end

    def coverage
      raw_data['coverage']
    end

    def network_id
      raw_data['network_id']
    end

    def network_name
      raw_data['network_name']
    end

    def part_of_id
      raw_data['partof_id']
    end

    def part_of_name
      raw_data['partof_display']
    end

    def phone_numbers
      @phone_numbers ||= [fake_phone_number]
    end

    def fax_numbers
      @fax_numbers ||= [fake_phone_number]
    end

    def address
      @address ||= OpenStruct.new(
        {
          lines: [
            raw_data['address']
          ].reject(&:blank?),
          city: raw_data['city'],
          state: raw_data['state'],
          zip: format_zip(raw_data['zip'])
        }
      )
    end
  end
end
