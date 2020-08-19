require_relative '../../lib/pdex'
require_relative '../../lib/pdex/nppes_managing_org'
require 'csv'

RSpec.describe PDEX::NPPESManagingOrg do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'plan.csv')
    [].tap do |plans|
      CSV.foreach(fixture_path, headers: true) do |row|
        plans << row
      end
    end
  end

  let(:raw_plan) { raw_plans.first }
  let(:plan) { described_class.new(raw_plan) }

  describe '.initialize' do
    it 'creates a NPPESManagingOrg instance' do
      expect(plan).to be_a(described_class)
    end
  end

  describe '#id' do
    it 'returns the plan id' do
      expect(plan.id).to eq('HPID240000')
    end

    it 'returns an id for payers' do
      payer_plan = described_class.new(raw_plan, payer: true)
      expect(payer_plan.id).to eq('1230120000')
    end
  end

  describe '#type' do
    it 'returns the type' do
      expect(plan.type).to be_present
    end
  end

  describe '#type_display' do
    it 'returns the type display' do
      expect(plan.type_display).to be_present
    end
  end

  describe '#name' do
    it 'returns the name' do
      expect(plan.name).to eq('Acme Insurance Co of MassachusettsBronze PPO Plan')
    end
  end

  describe '#alias' do
    it 'returns the alias' do
      expect(plan.alias).to eq('Acme MA BRONZE PPO')
    end
  end

  describe '#owner_id' do
    it 'returns the owner_id' do
      expect(plan.owner_id).to eq('1230210000')
    end
  end

  describe '#owner_name' do
    it 'returns the owner_name' do
      expect(plan.owner_name).to eq('Acme Insurance Co')
    end
  end

  describe '#administrator_id' do
    it 'returns the administrator_id' do
      expect(plan.administrator_id).to eq('1230210000')
    end
  end

  describe '#administrator_name' do
    it 'returns the administrator_name' do
      expect(plan.administrator_name).to eq('Acme Insurance Co')
    end
  end

  describe '#coverage' do
    it 'returns the coverage area' do
      expect(plan.coverage).to eq('Greater Boston Area')
    end
  end

  describe '#network_id' do
    it 'returns the network id' do
      expect(plan.network_id).to eq('HPID010000')
    end
  end

  describe '#network_name' do
    it 'returns the network name' do
      expect(plan.network_name).to eq('Acme of Massachusetts Preferred Provider Network')
    end
  end

  describe '#part_of_id' do
    it 'returns the name' do
      expect(plan.part_of_id).to eq('9990210000')
    end
  end

  describe '#part_of_name' do
    it 'returns the name' do
      expect(plan.part_of_name).to eq('Acme Insurance Co')
    end
  end

  describe '#address' do
    it 'returns the address' do
      expect(plan.address).to be_present
    end
  end

  describe '#phone_numbers' do
    it 'returns random phone numbers' do
      expect(plan.phone_numbers).to be_present
    end
  end

  describe '#fax_numbers' do
    it 'returns random fax numbers' do
      expect(plan.fax_numbers).to be_present
    end
  end

  describe '#position' do
    it 'returns the position' do
      expect(plan.position).to be_present
    end
  end
end
