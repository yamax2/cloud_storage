# frozen_string_literal: true

RSpec.describe CloudStorage::Objects::Gcs do
  let(:cli) { gcs_new_client }
  let(:file) { File.open('spec/fixtures/test.txt', 'rb') }
  let!(:obj) { cli.upload_file(key: 'test_1.txt', file: file) }

  describe '#signed_url' do
    subject(:url) { obj.signed_url(expires_in: 30, issuer: 'max@tretyakov-ma.ru', signing_key: key) }

    after { obj.delete! }

    # we cannot sign url for anonymous without a key
    let(:key) { OpenSSL::PKey::RSA.new(File.read('spec/fixtures/dummy.key')) }

    it do
      expect(url).to match(%r{\Ahttps://storage.googleapis.com/some-bucket/test_1.txt})
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
        expect { obj.delete! }.to raise_error(Google::Cloud::NotFoundError)
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
