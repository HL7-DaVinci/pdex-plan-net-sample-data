module PDEX
  class NPPESDataRepo
    class << self
      def plans
        @plans ||= []
      end

      def payers
        @payers ||= []
      end

      def managing_orgs
        @managing_orgs ||= []
      end

      def networks
        @networks ||= []
      end

      def organizations
        @organizations ||= []
      end

      def practitioners
        @practitioners ||= []
      end

      def organization_networks
        @organization_networks ||= {}
      end

      def pharmacies
        @pharmacies ||= []
      end

      def pharmacy_orgs
        @pharmacy_orgs ||= []
      end

      # Use MA data if state has no data
      DEFAULT_STATE = 'MA'

      def networks_by_state(state)
        @networks_by_state ||= networks.group_by { |network| network.address.state }
        @networks_by_state[state] || @networks_by_state[DEFAULT_STATE]
      end

      def managing_orgs_by_state(state)
        @managing_orgs_by_state ||= managing_orgs.group_by { |org| org.address.state }
        @managing_orgs_by_state[state] || @managing_orgs_by_state[DEFAULT_STATE]
      end

      def organizations_by_state(state)
        @organizations_by_state ||= organizations.group_by { |org| org.address.state }
        @organizations_by_state[state] || @organizations_by_state[DEFAULT_STATE]
      end
    end
  end
end
