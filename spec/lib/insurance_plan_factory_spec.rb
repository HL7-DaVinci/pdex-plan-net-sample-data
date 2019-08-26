require_relative '../../lib/pdex'
require_relative '../../lib/pdex/insurance_plan_factory'
require_relative '../../lib/pdex/utils/nucc_codes'

RSpec.describe PDEX::InsurancePlanFactory do
  let(:plan) do
    OpenStruct.new(
      {
        id: 'abc',
        type: 'TYPE',
        type_display: 'TYPE DISPLAY',
        name: 'NAME',
        alias: 'ALIAS',
        owner_id: 'OWNER_ID',
        owner_name: 'OWNER NAME'
      }
    )
  end

  let(:factory) { described_class.new(plan) }
  let(:resource) { factory.build }
  let(:identifier) { resource.identifier.first }

  describe '.initialize' do
    it 'creates an InsurancePlanFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'returns an InsurancePlan' do
      expect(resource).to be_a(FHIR::InsurancePlan)
    end

    it 'includes an id' do
      expect(resource.id).to eq("plannet-insuranceplan-#{plan.id}")
    end

    it 'includes a meta field' do
      expect(resource.meta.profile.first).to eq(PDEX::INSURANCE_PLAN_PROFILE_URL)
    end

    it 'includes an identifier' do
      expect(identifier.type.text).to eq('HIOS product ID')
      expect(identifier.value).to eq(plan.id)
    end

    it 'includes a type' do
      expect(resource.type).to be_present
    end

    it 'includes a name' do
      expect(resource.name).to eq(plan.name)
    end

    it 'includes an alias' do
      expect(resource.alias).to eq([plan.alias])
    end

    it 'includes an owner reference' do
      expect(resource.ownedBy.reference).to eq("Organization/plannet-organization-#{plan.owner_id}")
      expect(resource.ownedBy.display).to eq(plan.owner_name)
    end

    it 'includes an administrator reference' do
      expect(resource.administeredBy.reference).to eq("Organization/plannet-organization-#{plan.administrator_id}")
      expect(resource.administeredBy.display).to eq(plan.administrator_name)
    end

    it 'includes coverage information' do
      expect(resource.coverage).to be_present
    end
  end
end
