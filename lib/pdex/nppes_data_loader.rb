require 'csv'
require_relative 'nppes_data_repo'

module PDEX
  class NPPESDataLoader
    NPPES_DIR = File.join(__dir__, '..', '..', '/sample-nppes-data')
    MANAGING_ORG_FILENAMES = File.join(NPPES_DIR, 'managing_orgs_data.csv')
    ORGANIZATION_FILENAMES = File.join(NPPES_DIR, 'sample-nppes-organization-data.csv')
    PRACTITIONER_FILENAMES = File.join(NPPES_DIR, 'sample-nppes-practitioner_20181204-data.csv')
    NETWORK_FILENAMES = File.join(NPPES_DIR, 'sample-nppes-network_20181204-data.csv')

    class << self
      def load
        load_managing_organizations
        load_networks
        load_organizations
        load_practitioners
      end

      private

      def load_managing_organizations
        CSV.foreach(MANAGING_ORG_FILENAMES, headers: true) do |row|
          if insurance_plan? row
            NPPESDataRepo.plans << PDEX::NPPESManagingOrg.new(row)
          elsif managing_org? row
            NPPESDataRepo.managing_orgs << PDEX::NPPESManagingOrg.new(row, managing_org: true)
          elsif payer? row
            NPPESDataRepo.payers << PDEX::NPPESManagingOrg.new(row, payer: true)
          end
        end
      end

      def insurance_plan?(row)
        row['is_plan'].downcase == 'true' && row['type'].downcase == 'ins'
      end

      def managing_org?(row)
        row['type'].downcase == 'prov' && row['is_plan'].downcase == 'false'
      end

      def payer?(row)
        row['type'].downcase == 'ins'
      end

      def load_networks
        CSV.foreach(NETWORK_FILENAMES, headers: true) do |row|
          NPPESDataRepo.networks << PDEX::NPPESNetwork.new(row)
        end
      end

      def load_organizations
        CSV.foreach(ORGANIZATION_FILENAMES, headers: true) do |row|
          NPPESDataRepo.organizations << PDEX::NPPESOrganization.new(row)
        end
      end

      def load_practitioners
        CSV.foreach(PRACTITIONER_FILENAMES, headers: true) do |row|
          NPPESDataRepo.practitioners << PDEX::NPPESPractitioner.new(row)
        end
      end
    end
  end
end
