# frozen_string_literal: true

RSpec.describe CloudStorage do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  it 'has two registered wrappers' do
    expect(described_class.instance_variable_get(:@wrappers).keys)
      .to match_array(%i[gcs s3])
  end

  describe 'wrapper registration' do
    subject(:register) { described_class.register_wrapper(klass) }

    context 'when correct wrapper' do
      subject(:register) do
        allow(described_class).to receive(:register_wrapper)

        stub_const(
          'CloudStorage::Wrappers::Test',
          Class.new(CloudStorage::Wrappers::Base)
        )

        allow(described_class).to receive(:register_wrapper).and_call_original
        described_class.register_wrapper(CloudStorage::Wrappers::Test)
      end

      it do
        expect { register }
          .to change { described_class[:test]&.to_s }.from(nil).to('CloudStorage::Wrappers::Test')
      end
    end

    context 'when already registered' do
      let(:klass) { CloudStorage::Wrappers::Gcs }

      it do
        expect { register }.to raise_error(/wrapper already registered:/)
      end
    end

    context 'when incorrect wrapper' do
      let(:klass) { String }

      it do
        expect { register }.to raise_error(/String should be subclass of.+Base/)
      end
    end
  end

  describe 'client' do
    context 'when gcs' do
      let(:cli) do
        described_class::Client.new(
          :gcs,
          anonymous: true,
          bucket: 'some-bucket',
          endpoint: ENV.fetch('GCS_ENDPOINT')
        )
      end

      it { expect(cli.type).to eq(:gcs) }
    end

    context 'when s3' do
      let(:cli) { described_class::Client.new('s3', bucket: 'zozo') }

      it { expect(cli.type).to eq(:s3) }
    end

    context 'when wrong' do
      it do
        expect { described_class::Client.new(:wrong, bucket: 'zozo') }
          .to raise_error('wrapper is not registered for type "wrong"')
      end
    end
  end
end
