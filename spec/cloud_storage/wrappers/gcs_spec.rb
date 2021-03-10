# frozen_string_literal: true

RSpec.describe CloudStorage::Wrappers::Gcs do
  let(:cli) { gcs_new_client }

  describe '#upload_file' do
    subject(:uploaded) { cli.upload_file(key: 'test1.txt', file: file) }

    let(:file) { File.open('spec/fixtures/test.txt', 'rb') }

    after { uploaded.delete! }

    it do
      expect { uploaded }.to change { cli.exist?('test1.txt') }.from(false).to(true)

      expect(uploaded).to have_attributes(
        name: 'test1.txt',
        key: 'test1.txt',
        size: nil
      )
    end
  end

  describe '#files' do
    subject(:files) { cli.files.to_a }

    before { cli.files.each(&:delete!) }

    after { cli.files.each(&:delete!) }

    context 'when bucket is empty' do
      it { is_expected.to be_empty }
    end

    context 'when some files' do
      let(:file) { File.open('spec/fixtures/test.txt', 'rb') }

      before do
        cli.upload_file(key: 'test2.txt', file: file)
        file.rewind
        cli.upload_file(key: 'another_test.txt', file: file)
      end

      context 'when request without opts' do
        it do
          expect(files.size).to eq(2)
          expect(files.map(&:name)).to match_array(%w[test2.txt another_test.txt])
        end
      end

      context 'when request with gcs client opts' do
        subject(:files) { cli.files(prefix: 'another').to_a }

        it do
          expect(files.size).to eq(1)
          expect(files.first.name).to eq('another_test.txt')
        end
      end
    end
  end

  describe '#exist?' do
    context 'when file exists' do
      let(:file) { File.open('spec/fixtures/test.txt', 'rb') }
      let!(:obj) { cli.upload_file(key: 'test3.txt', file: file) }

      after { obj.delete! }

      it do
        expect(cli.exist?('test3.txt')).to eq(true)
      end
    end

    context 'when file does not exist' do
      before { cli.files.each(&:delete!) }

      it do
        expect(cli.exist?('test4.txt')).to eq(false)
      end
    end
  end

  describe '#find' do
    context 'when file exists' do
      let(:file) { File.open('spec/fixtures/test.txt', 'rb') }
      let!(:obj) { cli.upload_file(key: 'test5.txt', file: file) }

      after { obj.delete! }

      it do
        expect(cli.find('test5.txt').download.read).to eq("This is a test upload\n")
      end
    end

    context 'when file does not exist' do
      it do
        expect { cli.find('test6.txt') }.to raise_error(CloudStorage::ObjectNotFound, /test6.txt/)
      end
    end
  end

  describe 'type' do
    it { expect(cli.type).to eq(:gcs) }
  end
end
