require_relative '../../lib/pdex'
require_relative '../../lib/pdex/location_factory'
require_relative '../../lib/pdex/utils/nucc_codes'

RSpec.describe PDEX::LocationFactory do
  let(:nppes_data) do
    OpenStruct.new(
      {
        npi: '1740283779',
        name: 'NAME HEALTHCARE, INC.',
        phone_numbers: [
          '1234567890',
          '2345678901'
        ],
        fax_numbers: [
          '0987654321'
        ],
        address: address,
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

  let(:factory) { described_class.new(nppes_data) }
  let(:resource) { factory.build }
  let(:extensions) { resource.extension }
  let(:accessibility_extensions) do
    extensions.select { |extension| extension.url == PDEX::ACCESSIBILITY_EXTENSION_URL }
  end

  let(:new_patient_extensions) do
    extensions.select { |extension| extension.url == PDEX::NEW_PATIENTS_EXTENSION_URL }
  end

  let(:new_patient_profile_extensions) do
    extensions.select { |extension| extension.url == PDEX::NEW_PATIENT_PROFILE_EXTENSION_URL }
  end

  describe '.initialize' do
    it 'creates a LocationFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'returns a Location' do
      expect(resource).to be_a(FHIR::Location)
    end

    it 'includes an id' do
      expect(resource.id).to be_present
    end

    it 'includes a meta field' do
      expect(resource.meta.profile.first).to eq(PDEX::LOCATION_PROFILE_URL)
    end

    it 'includes an accessibility extension' do
      expect(accessibility_extensions).to be_present
    end

    it 'includes new patient extensions' do
      expect(new_patient_extensions).to be_present
    end

    it 'includes new patient profile extensions' do
      expect(new_patient_profile_extensions).to be_present
    end

    it 'includes an identifier' do
      identifier = resource.identifier.first
      expect(identifier.system).to eq('https://name-healthcare-inc.com')
      expect(identifier.assigner.reference).to eq("Organization/vhdir-organization-#{nppes_data.npi}")
    end

    it 'includes a name' do
      expect(resource.name).to eq(nppes_data.name)
    end

    it 'includes phone and fax numbers' do
      telecom = resource.telecom
      phone_numbers = telecom.select { |entry| entry.system == 'phone' }.map(&:value)
      fax_numbers = telecom.select { |entry| entry.system == 'fax' }.map(&:value)

      expect(phone_numbers).to eq(nppes_data.phone_numbers)
      expect(fax_numbers).to eq(nppes_data.fax_numbers)
      telecom.each do |telecom_entry|
        extensions = telecom_entry.extension.select { |extension| extension.url = PDEX::CONTACT_POINT_AVAILABLE_TIME_EXTENSION_URL }
        expect(extensions).to be_present
      end
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
        expect(resource.address.send(key)).to eq(value)
      end
    end

    it 'includes a managing organization' do
      expect(resource.managingOrganization).to be_present
    end

    it 'includes hours of operation' do
      expect(resource.hoursOfOperation).to be_present
    end

    it 'includes availability exceptions' do
      expect(resource.availabilityExceptions).to be_present
    end
  end
end
