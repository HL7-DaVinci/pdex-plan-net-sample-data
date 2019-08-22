require_relative '../../lib/pdex'
require_relative '../../lib/pdex/network_factory'

RSpec.describe PDEX::NetworkFactory do
  let(:network) do
    OpenStruct.new(
      npi: '1740283779',
      type: type,
      name: 'NAME',
      phone_numbers: ['1234567890'],
      fax_numbers: [],
      address: address,
      part_of_id: 'PART_OF_ID',
      part_of_name: 'PART_OF'
    )
  end

  let(:type) do
    {
      code: 'TYPE_CODE',
      display: 'TYPE_DISPLAY',
      text: 'TYPE_TEXT'
    }
  end

  let(:address) do
    OpenStruct.new(
      lines: ['1000 ASYLUM AVE'],
      city: 'HARTFORD',
      state: 'CT',
      zip: '061051770'
    )
  end

  let(:factory) { described_class.new(network) }
  let(:resource) { factory.build }
  let(:identifier) { resource.identifier.first }
  let(:contact) { resource.contact.first }

  describe '.initialize' do
    it 'creates an NetworkFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'returns a Organization' do
      expect(resource).to be_a(FHIR::Organization)
    end

    it 'includes an id' do
      expect(resource.id).to eq("plannet-network-#{network.npi}")
    end

    it 'includes a meta field' do
      expect(resource.meta.profile.first).to eq(PDEX::NETWORK_PROFILE_URL)
    end

    it 'includes an identifier' do
      expect(identifier.type.coding.first.code).to eq('NIIP')
      expect(identifier.value).to eq(network.npi)
    end

    it 'includes a type' do
      expect(resource.type).to be_present
    end

    it 'includes a name' do
      expect(resource.name).to eq(network.name)
    end

    it 'includes an address' do
      expected_address = {
        use: 'work',
        type: 'both',
        text: "#{address.lines.first}, #{address.city}, #{address.state} #{address.zip}",
        line: address.lines,
        city: address.city,
        state: address.state,
        postalCode: address.zip,
        country: 'USA'
      }

      expected_address.each do |key, value|
        expect(resource.address.first.send(key)).to eq(value)
      end
    end

    it 'includes contact information' do
      expect(contact.name).to be_present
      expect(contact.purpose.coding.first.code).to eq('ADMIN')
      expect(contact.telecom.first.extension).to be_present
      expect(contact.address).to be_present
    end

    it 'includes a part of reference' do
      expect(resource.partOf).to be_present
      expect(resource.partOf.reference).to eq('Organization/plannet-organization-PART_OF_ID')
      expect(resource.partOf.display).to eq('PART_OF')
    end
  end
end
