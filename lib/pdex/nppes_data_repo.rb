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
    end
  end
end
