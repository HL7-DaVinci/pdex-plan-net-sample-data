require_relative '../../lib/pdex'
require_relative '../../lib/pdex/nppes_organization'
require 'csv'

RSpec.describe PDEX::NPPESOrganization do
  let(:raw_organizations) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'organization.csv')
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
    it 'returns the npi' do
      expect(organization.npi).to eq('1982607537')
    end
  end

  describe '#name' do
    it 'returns the name' do
      expect(organization.name).to eq('GREATER NEW BEDFORD COMMUNITY HEALTH CENTER, INC.')
    end
  end

  describe '#phone' do
    it 'returns the phone number' do
      expect(organization.phone).to eq('5089926553')
    end
  end

  describe '#address' do
    it 'returns the address' do
      expected_address = OpenStruct.new(
        {
          lines: ['874 PURCHASE ST'],
          city: 'NEW BEDFORD',
          state: 'MA',
          zip: '02740'
        }
      )

      expect(organization.address).to eq(expected_address)
    end
  end
end
