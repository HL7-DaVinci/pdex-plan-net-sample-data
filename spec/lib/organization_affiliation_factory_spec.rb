require_relative '../../lib/pdex'
require_relative '../../lib/pdex/organization_affiliation_factory'

RSpec.describe PDEX::OrganizationAffiliationFactory do
  let(:organization) do
    OpenStruct.new(
      {
        npi: '1740283779',
        name: 'NAME'
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

  let(:network) do
    OpenStruct.new(
      {
        id: 'vhdir-organization-54321',
        name: 'NETWORK'
      }
    )
  end

  let(:managing_org) do
    OpenStruct.new(
      {
        id: 'vhdir-organization-12345',
        name: 'MANAGING ORG'
      }
    )
  end

  let(:factory) { described_class.new(organization, network: network, managing_org: managing_org) }
  let(:resource) { factory.build }
  let(:identifier) { resource.identifier.first }

  describe '.initialize' do
    it 'creates an OrganizationAffiliationFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'returns an OrganizationAffiliation' do
      expect(resource).to be_a(FHIR::OrganizationAffiliation)
    end

    it 'includes an id' do
      expect(resource.id).to be_present
    end

    it 'includes a meta field' do
      expect(resource.meta.profile.first).to eq(PDEX::ORGANIZATION_AFFILIATION_PROFILE_URL)
    end

    it 'includes an identifier' do
      expect(identifier.use).to eq('secondary')
      expect(identifier.value).to be_present
      expect(identifier.assigner.display).to be_present
    end

    it 'includes an organization reference' do
      expect(resource.organization).to be_present
    end

    it 'includes a participatingOrganization reference' do
      expect(resource.participatingOrganization).to be_present
    end

    it 'includes a code' do
      expect(resource.code).to be_present
      expect(resource.code.first.coding).to be_present
    end
  end
end
