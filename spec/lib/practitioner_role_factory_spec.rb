require_relative '../../lib/pdex'
require_relative '../../lib/pdex/practitioner_role_factory'

RSpec.describe PDEX::PractitionerRoleFactory do
  let(:nppes_practitioner) do
    OpenStruct.new(
      {
        npi: '1740283779',
        name: OpenStruct.new(
          {
            first: 'First',
            middle: 'Middle',
            last: 'Last',
            prefix: 'Prefix'
          }
        ),
        phone_numbers: [
          '1234567890',
          '2345678901'
        ],
        fax_numbers: [
          '0987654321'
        ],
        qualifications: qualifications
      }
    )
  end

  let(:organization) do
    OpenStruct.new(
      {
        npi: '1234567890',
        name: 'ORGANIZATION'
      }
    )
  end

  let(:network) do
    OpenStruct.new(
      {
        npi: '0987654321',
        name: 'NETWORK'
      }
    )
  end
  let(:qualifications) do
    [
      OpenStruct.new(
        {
          state: 'MA',
          license_number: '123',
          taxonomy_code: '2085H0002X'
        }
      )
    ]
  end

  let(:factory) { described_class.new(nppes_practitioner, organization: organization, networks: [network]) }

  let(:resource) { factory.build }

  describe '.initialize' do
    it 'creates a PractitionerRoleFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'returns a PractitionerRole' do
      expect(resource).to be_a(FHIR::PractitionerRole)
    end

    it 'includes an id' do
      expect(resource.id).to be_present
    end

    it 'includes a meta field' do
      expect(resource.meta.profile.first).to eq(PDEX::PRACTITIONER_ROLE_PROFILE_URL)
    end

    it 'includes an identifier' do
      identifier = resource.identifier.first
      type_coding = identifier.type.coding.first
      expect(type_coding.system).to eq('http://terminology.hl7.org/CodeSystem/v2-0203')
      expect(type_coding.code).to eq('PRN')
    end

    it 'includes a practitioner reference' do
      expect(resource.practitioner).to be_present
    end

    it 'includes a network extension' do
      expect(resource.extension.first.url).to eq(PDEX::NETWORK_REFERENCE_EXTENSION_URL)
    end

    it 'includes an organization reference' do
      expect(resource.organization).to be_present
    end

    it 'includes codes' do
      expect(resource.code.length).to eq(1)
      resource.code.each do |codeable_concept|
        coding = codeable_concept.coding.first
        expect(coding.system).to be_present
        expect(coding.code).to be_present
      end
    end

    it 'includes specialties' do
      expect(resource.specialty.length).to eq(qualifications.length)
      resource.specialty.each do |codeable_concept|
        coding = codeable_concept.coding.first
        expect(coding.system).to be_present
        expect(coding.code).to be_present
      end
    end

    it 'includes a location reference' do
      expect(resource.location).to be_present
    end

    it 'includes phone and fax numbers' do
      telecom = resource.telecom
      phone_numbers = telecom.select { |entry| entry.system == 'phone' }.map(&:value)
      fax_numbers = telecom.select { |entry| entry.system == 'fax' }.map(&:value)

      expect(phone_numbers).to eq(['1234567890', '2345678901'])
      expect(fax_numbers).to eq(['0987654321'])
    end
  end
end
