require_relative '../../lib/pdex'
require_relative '../../lib/pdex/practitioner_factory'
require_relative '../../lib/pdex/utils/nucc_codes'

RSpec.describe PDEX::PractitionerFactory do
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
        address: address,
        gender: 'F',
        qualifications: qualifications
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

  let(:factory) { described_class.new(nppes_practitioner) }

  let(:resource) { factory.build }

  describe '.initialize' do
    it 'creates a PractitionerFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'returns a Practitioner' do
      expect(resource).to be_a(FHIR::Practitioner)
    end

    it 'includes an id' do
      expect(resource.id).to be_present
    end

    it 'includes a meta field' do
      expect(resource.meta.profile.first).to eq(PDEX::PRACTITIONER_PROFILE_URL)
    end

    it 'includes an identifier' do
      identifier = resource.identifier.first
      type_coding = identifier.type.coding.first
      expect(type_coding.system).to eq('http://terminology.hl7.org/CodeSystem/v2-0203')
      expect(type_coding.code).to eq('PRN')
      expect(identifier.value).to eq(nppes_practitioner.npi)
      expect(identifier.system).to eq('http://hl7.org/fhir/sid/us-npi')
    end

    it 'includes a name' do
      name = resource.name.first
      expect(name.given).to eq(['First', 'Middle'])
      expect(name.family).to eq('Last')
      expect(name.prefix).to eq(['Prefix'])
      expect(name.suffix).to be_blank
    end

    it 'includes phone and fax numbers' do
      telecom = resource.telecom
      phone_numbers = telecom.select { |entry| entry.system == 'phone' }.map(&:value)
      fax_numbers = telecom.select { |entry| entry.system == 'fax' }.map(&:value)

      expect(phone_numbers).to eq(['1234567890', '2345678901'])
      expect(fax_numbers).to eq(['0987654321'])
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

    it 'includes a gender' do
      expect(resource.gender).to eq('female')
    end

    it 'includes qualifications' do
      expect(resource.qualification.length).to eq(nppes_practitioner.qualifications.length)
      qualification_display = PDEX::NUCCCodes.display(nppes_practitioner.qualifications.first.taxonomy_code)
      expect(resource.qualification.first.code.text).to eq(qualification_display)
      expect(resource.qualification.first.code.coding.first.display).to eq(qualification_display)
      expect(resource.qualification.first.code.coding.first.code).to eq(qualifications.first.taxonomy_code)
    end

    it 'includes communication' do
      expect(resource.communication).to be_present
      proficiency_extensions_present = resource.communication.all? do |communication|
        communication.extension.any? do |extension|
          extension.url == PDEX::COMMUNICATION_PROFICIENCY_EXTENSION_URL
        end
      end
      expect(proficiency_extensions_present).to eq(true)
    end
  end
end
