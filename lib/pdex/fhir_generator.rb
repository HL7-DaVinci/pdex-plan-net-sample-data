module PDEX
  class FHIRGenerator
    class << self
      def generate
        generate_insurance_plans
        generate_managing_orgs
        generate_payers
        generate_networks
        generate_organizations
        generate_locations
        generate_endpoints
        generate_healthcare_services
        generate_organization_affiliations
        generate_practitioners
        generate_practitioner_roles
      end

      def write_resource(resource)
        File.write("output/#{resource.resourceType}/#{resource.id}.json", resource.to_json)
      end

      def generate_insurance_plans
      end

      def generate_managing_orgs
      end

      def generate_payers
      end

      def generate_networks
      end

      def generate_organizations
      end

      def generate_locations
      end

      def generate_endpoints
      end

      def generate_healthcare_services
      end

      def generate_organization_affiliations
      end

      def generate_practitioners
      end

      def generate_practitioner_roles
      end
    end
  end
end
