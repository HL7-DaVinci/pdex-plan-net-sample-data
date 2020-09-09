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
      expect(network.name).to eq('Acme of Massachusetts Preferred Provider Network')
    end
  end

  describe '#phone_numbers' do
    it 'returns an array of phone numbers' do
      expect(network.phone_numbers).to be_present
    end
  end

  describe '#fax_numbers' do
    it 'returns an empty array' do
      expect(network.fax_numbers).to be_present
    end
  end

  describe '#address' do
    it 'returns the address' do
      expected_address = OpenStruct.new(
        {
          lines: ['874 PURCHASE ST'],
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

  describe '#part_of_id' do
    it 'returns the name' do
      expect(network.part_of_id).to eq('1230120000')
    end
  end

  describe '#part_of_name' do
    it 'returns the name' do
      expect(network.part_of_name).to eq('Acme Insurance Co')
    end
  end

  describe '#position' do
    it 'returns the position' do
      expect(network.position).to be_present
    end
  end
end
