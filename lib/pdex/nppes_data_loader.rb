require 'csv'
require_relative 'nppes_data_repo'
require_relative 'shortname'

module PDEX

  class NPPESDataLoader

    DATA_DIR = File.join(__dir__, '..', '..', '/sample-data')
    MANAGING_ORG_FILENAMES = File.join(DATA_DIR, 'managing_orgs_data.csv')
    ORGANIZATION_FILENAMES = File.join(DATA_DIR, 'sample-nppes-organization-data.csv')
    PHARMACY_FILENAMES = File.join(DATA_DIR, 'ct_pharmacies.csv')
    PRACTITIONER_FILENAMES = File.join(DATA_DIR, 'sample-nppes-practitioner_20181204-data.csv')
    NETWORK_FILENAMES = File.join(DATA_DIR, 'sample-nppes-network_20181204-data.csv')

    class << self
    include ShortName
    def load
        load_managing_organizations
        load_networks
        load_organizations
        load_practitioners
        load_pharmacies
        load_pharmacy_orgs
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

      def load_pharmacies
        CSV.foreach(PHARMACY_FILENAMES, headers: true) do |row|
          NPPESDataRepo.pharmacies << PDEX::PharmacyData.new(row)
        end
      end

      def load_pharmacy_orgs
        # - iterate through NPPESDataRepo.pharmacies and generate PharmacyOrg
        #   objects to hold the data
        # - add the pharmacy orgs to NPPESDataRepo.pharmacy_orgs

        unique_org_names = NPPESDataRepo.pharmacies.map{ |pharmacy| short_name(pharmacy.name)}.uniq.sort 
         unique_org_names.each {|name| 
          NPPESDataRepo.pharmacy_orgs << PDEX::PharmacyOrgData.new(name)
        }
      end
    end
  end
end
