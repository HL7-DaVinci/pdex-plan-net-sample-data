require_relative '../../lib/pdex/endpoint_factory'

RSpec.describe PDEX::EndpointFactory do
  let(:factory) { described_class.new(source_data, resource_type) }
  let(:resource) { factory.build }
  let(:contact) { resource.contact.first }
  let(:identifier) { resource.identifier.first }
  let(:use_case) { resource.extension.find { |extension| extension.url == PDEX::ENDPOINT_USE_CASE_EXTENSION_URL } }

  # These are overridden in the #build tests
  let(:source_data) { {} }
  let(:resource_type) { '' }

  describe '.initialize' do
    it 'creates an EndpointFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    context 'for an organization' do
      let(:resource_type) { 'Organization' }
      let(:source_data) do
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

      it 'returns an Endpoint' do
        expect(resource).to be_a(FHIR::Endpoint)
      end

      it 'includes an id' do
        expect(resource.id).to be_present
      end

      it 'includes a meta field' do
        expect(resource.meta.profile.first).to eq(PDEX::ENDPOINT_PROFILE_URL)
      end

      it 'includes an address' do
        expect(resource.address).to be_present
      end

      it 'includes a name' do
        expect(resource.name).to eq("#{source_data.name} Direct Address")
      end

      it 'includes a managing organization reference' do
        expect(resource.managingOrganization.display).to eq(source_data.name)
        expect(resource.managingOrganization.reference).to eq("Organization/plannet-organization-#{source_data.npi}")
      end

      it 'includes contact information' do
        expect(contact.system).to eq('phone')
        expect(contact.value).to eq('1234567890')
      end

      it 'includes a use case' do
        expect(use_case).to be_present
      end
    end
  end
end
