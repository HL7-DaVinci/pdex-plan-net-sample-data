require_relative '../../lib/pdex'
require_relative '../../lib/pdex/organization_factory'
require_relative '../../lib/pdex/utils/nucc_codes'

RSpec.describe PDEX::OrganizationFactory do
  let(:organization) do
    OpenStruct.new(
      {
        npi: '1740283779',
        name: 'NAME',
        phone_numbers: [
          '1234567890',
          '2345678901'
        ],
        fax_numbers: [
          '0987654321'
        ],
        address: address,
        contact_first_name: 'FNAME',
        contact_last_name: 'LNAME'
      }
    )
  end

  let(:address) do
    OpenStruct.new(
      {
        lines: ['1000 ASYLUM AVE', 'STE 4309'],
        city: 'HARTFORD',
        state: 'CT',
        zip: '061051770'
      }
    )
  end

  let(:factory) { described_class.new(organization) }
  let(:resource) { factory.build }
  let(:telecom) { resource.telecom.first }
  let(:identifier) { resource.identifier.first }
  let(:contact) { resource.contact.first }

  describe '.initialize' do
    it 'creates an OrganizationFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'returns a Organization' do
      expect(resource).to be_a(FHIR::Organization)
    end

    it 'includes an id' do
      expect(resource.id).to be_present
    end

    it 'includes a meta field' do
      expect(resource.meta.profile.first).to eq(PDEX::ORGANIZATION_PROFILE_URL)
    end

    it 'includes an identifier' do
      expect(identifier.type.coding.first.code).to eq('NPI')
      expect(identifier.value).to eq(organization.npi)
    end

    it 'includes a type' do
      expect(resource.type).to be_present
    end

    it 'includes a name' do
      expect(resource.name).to eq(organization.name)
    end

    it 'includes a phone number' do
      expect(telecom.system).to eq('phone')
      expect(telecom.value).to eq('1234567890')
    end

    it 'includes an address' do
      expected_address = {
        use: 'work',
        type: 'both',
        text: "#{address.lines.first}, #{address.lines.last}, #{address.city}, #{address.state} #{address.zip}",
        line: [address.lines.first, address.lines.last],
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

    it "doesn't include contact information for payers" do
      payer = described_class.new(organization, payer: true).build
      expect(payer.contact).to be_blank
    end

    it 'includes a no identifier for pharmacies' do
      pharmacy = described_class.new(organization, pharmacy: true).build
      expect(pharmacy.identifier).to be_blank
    end
  end
end
