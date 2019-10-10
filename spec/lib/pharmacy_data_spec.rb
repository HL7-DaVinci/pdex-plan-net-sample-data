require_relative '../../lib/pdex'
require_relative '../../lib/pdex/pharmacy_data'
require 'csv'

RSpec.describe PDEX::PharmacyData do
  let(:raw_organizations) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'pharmacy.csv')
    [].tap do |organizations|
      CSV.foreach(fixture_path, headers: true) do |row|
        organizations << row
      end
    end
  end

  let(:raw_organization) { raw_organizations.first }
  let(:organization) { described_class.new(raw_organization) }

  describe '.initialize' do
    it 'creates a NPPESOrganization instance' do
      expect(organization).to be_a(described_class)
    end
  end

  describe '#npi' do
    it 'returns the pharmacy credential' do
      expect(organization.npi).to eq('PCY-0007322')
    end
  end

  describe '#name' do
    it 'returns the name' do
      expect(organization.name).to eq('WHALLEY DRUG')
    end
  end

  describe '#contact_first_name' do
    it 'returns the name' do
      expect(organization.contact_first_name).to be_present
    end
  end

  describe '#contact_last_name' do
    it 'returns the name' do
      expect(organization.contact_last_name).to be_present
    end
  end

  describe '#phone_numbers' do
    it 'returns an array of phone numbers' do
      expect(organization.phone_numbers).to be_present
    end
  end

  describe '#fax_numbers' do
    it 'returns an array of fax numbers' do
      expect(organization.fax_numbers).to be_present
    end
  end

  describe '#address' do
    it 'returns the address' do
      expected_address = OpenStruct.new(
        {
          lines: ['399 WHALLEY AVE'],
          city: 'NEW HAVEN',
          state: 'CT',
          zip: '06511-3008'
        }
      )

      expect(organization.address).to eq(expected_address)
    end
  end

  describe '#position' do
    it 'returns the position' do
      expect(organization.position).to be_present
    end
  end
end
