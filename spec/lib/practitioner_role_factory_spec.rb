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

  let(:factory) { described_class.new(nppes_practitioner, organization: organization) }

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

    # it 'includes an address' do
    #   expected_address = {
    #     use: 'work',
    #     type: 'both',
    #     text: "#{address.lines.first}, #{address.lines.last}, #{address.city}, #{address.state} #{address.zip}",
    #     line: [address.lines.first, address.lines.last],
    #     city: address.city,
    #     state: address.state,
    #     postalCode: address.zip,
    #     country: 'USA'
    #   }

    #   expected_address.each do |key, value|
    #     expect(resource.address.first.send(key)).to eq(value)
    #   end
    # end

    # it 'includes a gender' do
    #   expect(resource.gender).to eq('female')
    # end

    # it 'includes qualifications' do
    #   expect(resource.qualification.length).to eq(nppes_practitioner.qualifications.length)
    #   qualification_display = PDEX::NUCCCodes.display(nppes_practitioner.qualifications.first.taxonomy_code)
    #   expect(resource.qualification.first.code.text).to eq(qualification_display)
    #   expect(resource.qualification.first.code.coding.first.display).to eq(qualification_display)
    #   expect(resource.qualification.first.code.coding.first.code).to eq(qualifications.first.taxonomy_code)
    # end
  end
end
