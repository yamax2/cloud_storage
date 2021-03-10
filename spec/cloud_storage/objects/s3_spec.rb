# frozen_string_literal: true

RSpec.describe CloudStorage::Objects::S3 do
  let(:cli) { s3_new_client }
  let(:file) { File.open('spec/fixtures/test.txt', 'rb') }
  let!(:obj) { cli.upload_file(key: 'test_1.txt', file: file) }

  describe '#signed_url' do
    subject(:url) { obj.signed_url(expires_in: 30) }

    after { obj.delete! }

    it do
      expect(url).to match(%r{\A#{ENV['S3_ENDPOINT']}/#{ENV['S3_BUCKET']}/test_1.txt})
    end
  end

  describe '#delete!' do
    context 'when file exists' do
      it do
        expect { obj.delete! }
          .to change { cli.exist?('test_1.txt') }.from(true).to(false)
      end
    end

    context 'when file does not exist' do
      before { obj.delete! }

      it do
        expect { obj.delete! }.not_to(change { cli.exist?('test_1.txt') })
      end
    end
  end

  describe '#download' do
    after { obj.delete! }

    context 'when default' do
      it do
        expect(obj.download.read).to eq("This is a test upload\n")
      end
    end

    context 'when download to a custom tmp' do
      let(:tmp) { Tempfile.new }

      it do
        expect { obj.download(tmp) }.to change(tmp, :read).from('').to("This is a test upload\n")
      end
    end
  end
end
