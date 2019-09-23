require_relative '../../lib/pdex/nppes_data_repo.rb'

RSpec.describe PDEX::NPPESDataRepo do
  let(:ma_data) { OpenStruct.new(address: OpenStruct.new(state: 'MA')) }
  let(:ri_data) { OpenStruct.new(address: OpenStruct.new(state: 'RI')) }

  describe '.networks_by_state' do
    before do
      allow(described_class).to receive(:networks) { [ma_data, ri_data] }
    end

    it 'returns network data grouped by state' do
      expect(described_class.networks_by_state('MA')).to eq([ma_data])
      expect(described_class.networks_by_state('RI')).to eq([ri_data])
    end
  end

  describe '.managing_orgs_by_state' do
    before do
      allow(described_class).to receive(:managing_orgs) { [ma_data, ri_data] }
    end

    it 'returns network data grouped by state' do
      expect(described_class.managing_orgs_by_state('MA')).to eq([ma_data])
      expect(described_class.managing_orgs_by_state('RI')).to eq([ri_data])
    end
  end

  describe '.organizations_by_state' do
    before do
      allow(described_class).to receive(:organizations) { [ma_data, ri_data] }
    end

    it 'returns network data grouped by state' do
      expect(described_class.organizations_by_state('MA')).to eq([ma_data])
      expect(described_class.organizations_by_state('RI')).to eq([ri_data])
    end
  end
end
