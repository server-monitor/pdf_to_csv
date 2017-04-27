
# rubocop:disable Metrics/BlockLength

require 'httparty'
require 'fileutils'
require 'open3'

TargetFile.new.setup

RSpec.describe PDF do
  let(:remote_file) do
    'https://www.cityofrc.us/civicax/filebank/blobdload.aspx?BlobID=29994'.freeze
  end

  let(:dest_file) { '/tmp/pdf.pdf' }

  let(:bin_file) { SPEC_DATA_DIR.join('file.pdf'.freeze).freeze }
  let(:contents) { open(bin_file, 'rb'.freeze, &:read) }
  let(:response) { double('...', parsed_response: contents) }

  before { allow(HTTParty).to receive(:get).and_return(response) }

  let(:instance) { PDF.new(remote_file, dest_file) }

  describe 'attributes' do
    subject { PDF.new 'abcd', 'efgh' }
    %i[
      file
    ].each do |attrib|
      it { should respond_to attrib }
    end
  end

  download_method = :download
  describe download_method do
    let(:uut) { instance.public_send(download_method) }

    specify { expect(instance).to respond_to download_method }

    specify 'should return self so we can chain stuff' do
      expect(uut).to eq instance
    end

    context 'when file exists' do
      it 'should not download the file' do
        allow(File).to receive_messages(file?: true)
        expect(HTTParty).to_not receive(:get)
        uut
      end
    end

    context 'when file does not exist' do
      before { FileUtils.rm dest_file if File.file? dest_file }

      describe HTTParty do
        it 'should make a call to get' do
          expect(HTTParty).to receive(:get).with(remote_file).once
          uut
        end

        context 'using dowloader passed in' do
          it 'should make a call to get' do
            expect(HTTParty).to receive(:get).with(remote_file).once

            TargetFile.new.setup('downloader')
            fetcher = Downloader.new
            PDF.new(remote_file, dest_file, downloader: fetcher).public_send(
              download_method
            )
          end
        end
      end

      describe "#{HTTParty} response" do
        it 'should make a call to parsed_response' do
          expect(response).to receive(:parsed_response).once
          uut
        end
      end

      it 'should download the file' do
        uut
        expect(FileUtils.compare_file(bin_file, dest_file)).to eq true
      end
    end
  end

  to_csv_method = :to_csv

  describe to_csv_method do
    let(:dest_csv_file) { '/tmp/spec_dest.csv'.freeze }

    let(:csv_file) { SPEC_DATA_DIR.join('file.csv'.freeze).freeze }
    let(:contents) { open(csv_file, 'rb'.freeze, &:read) }
    let(:capture_success) do
      [
        contents,
        nil,
        double('Process::Status', exited?: true, success?: true)
      ]
    end

    before { allow(Open3).to receive(:capture3).and_return(capture_success) }
    before { FileUtils.rm dest_csv_file if File.file? dest_csv_file }

    let(:uut) { instance.public_send(to_csv_method, dest_csv_file) }

    specify { expect(instance).to respond_to to_csv_method }

    specify 'should return self so we can chain stuff' do
      allow(File).to receive(:file?).and_return(true)

      expect(uut).to eq instance
    end

    context 'when csv file exists' do
      specify do
        allow(File).to receive(:file?).and_return(true)
        expect(Open3).to_not receive(:capture3)
        uut
      end
    end

    context 'when csv file does not exist' do
      specify do
        allow(File).to receive(:file?).and_return(false)
        expect(Open3).to receive(:capture3).once
        uut
      end

      it 'should create csv file' do
        uut
        expect(FileUtils.compare_file(csv_file, dest_csv_file)).to eq true
      end
    end
  end
end
