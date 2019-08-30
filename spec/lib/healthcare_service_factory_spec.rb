require_relative '../../lib/pdex/healthcare_service_factory'

RSpec.describe PDEX::HealthcareServiceFactory do
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
        contact_first_name: 'FNAME',
        contact_last_name: 'LNAME'
      }
    )
  end

  let(:factory) { described_class.new(organization, type) }
  let(:resource) { factory.build }
  let(:type) { 'administration' }
  let(:telecom) { resource.telecom.first }
  let(:identifier) { resource.identifier.first }
  let(:new_patients_extension) { resource.extension.find { |extension| extension.url == PDEX::NEW_PATIENTS_EXTENSION_URL } }

  describe '.initialize' do
    it 'creates an HealthcareServiceFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'returns a HealthcareService' do
      expect(resource).to be_a(FHIR::HealthcareService)
    end

    it 'includes an id' do
      expect(resource.id).to be_present
    end

    it 'includes a meta field' do
      expect(resource.meta.profile.first).to eq(PDEX::HEALTHCARE_SERVICE_PROFILE_URL)
    end

    it 'includes an identifier' do
      expect(identifier.type.coding.first.code).to eq('PRN')
      expect(identifier.value).to eq("#{organization.npi}-#{type}")
    end

    it 'includes providedBy' do
      expect(resource.providedBy).to be_present
    end

    it 'includes a type' do
      expect(resource.type).to be_present
    end

    it 'includes a location reference' do
      expect(resource.location).to be_present
    end

    it 'includes a name' do
      expect(resource.name).to eq(organization.name)
    end

    it 'includes a phone number' do
      expect(telecom.system).to eq('phone')
      expect(telecom.value).to eq('1234567890')
    end

    it 'includes a comment' do
      expect(resource.comment).to be_present
      expect(resource.comment).to eq 'Registered Nurse/Administrator, Specialist/Technologist, Health Information/Registered Record Administrator, Pathology/Clinical Laboratory Director, Non-physician'
    end

    it 'includes specalties' do
      expect(resource.specialty).to be_present
      expect(resource.specialty.length).to eq(3)
    end

    it 'includes a new patients extension' do
      expect(new_patients_extension).to be_present
    end
  end
end
