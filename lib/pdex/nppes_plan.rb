# require_relative 'utils/formatting'

module PDEX
  class NPPESPlan
    # include Formatting

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

    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data.freeze
    end

    def id
      raw_data['plan_id']
    end

    def type
      raw_data['plan_type']
    end

    def type_display
      PLAN_TYPE_DISPLAY.fetch(type.to_sym)
    end

    def name
      raw_data['plan_name']
    end

    def alias
      raw_data['plan_alias']
    end

    def owner_id
      raw_data['id']
    end

    def owner_name
      raw_data['name']
    end

    def administrator_id
      raw_data['plan_manager_id']
    end

    def administrator_name
      raw_data['plan_manager']
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
  end
end
