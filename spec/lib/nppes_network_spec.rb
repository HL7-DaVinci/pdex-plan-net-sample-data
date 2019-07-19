require_relative '../../lib/pdex'
require_relative '../../lib/pdex/nppes_network'
require 'csv'

RSpec.describe PDEX::NPPESNetwork do
  let(:raw_networks) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'network.csv')
    [].tap do |networks|
      CSV.foreach(fixture_path, headers: true) do |row|
        networks << row
      end
    end
  end

  let(:raw_network) { raw_networks.first }
  let(:network) { described_class.new(raw_network) }

  describe '.initialize' do
    it 'creates a NPPESNetwork instance' do
      expect(network).to be_a(described_class)
    end
  end

  describe '#npi' do
    it 'returns the hpid' do
      expect(network.npi).to eq('HPID010000')
    end
  end

  describe '#type' do
    it 'returns the type' do
      expect(network.type).to be_present
    end
  end

  describe '#name' do
    it 'returns the name' do
      expect(network.name).to eq('Acme of Massechusetts Preferred Provider Network')
    end
  end

  describe '#phone_numbers' do
    it 'returns an array of phone numbers' do
      expect(network.phone_numbers).to eq(['6075555555'])
    end
  end

  describe '#fax_numbers' do
    it 'returns an empty array' do
      expect(network.fax_numbers).to eq([])
    end
  end

  describe '#address' do
    it 'returns the address' do
      expected_address = OpenStruct.new(
        {
          lines: ['120 St James Ave'],
          city: 'Boston',
          state: 'MA',
          zip: '02101'
        }
      )

      expect(network.address).to eq(expected_address)
    end
  end

  describe '#contact_first_name' do
    it 'returns a name' do
      expect(network.contact_first_name).to be_present
    end
  end

  describe '#contact_last_name' do
    it 'returns a name' do
      expect(network.contact_last_name).to be_present
    end
  end
end
