
# rubocop:disable Metrics/BlockLength

require 'httparty'
require 'fileutils'

TargetFile.new.setup

RSpec.describe Downloader do
  mut = :download

  it { should respond_to mut }

  describe mut do
    let(:uut) { Downloader.new }

    # HTTParty.get(remote_file).parsed_response ...
    #   => returns => contents of bin file

    let(:remote_file) { 'https://example.org/remote-file'.freeze }
    # let(:remote_file) do
    #   'https://www.cityofrc.us/civicax/filebank/blobdload.aspx?BlobID=29994'.freeze
    # end

    let(:dest_file) { '/tmp/pdf_to_csv_to_x_spec_lib_tool_downloader.bin' }

    let(:bin_file) { '/bin/ls'.freeze }
    let(:contents) { open(bin_file, 'rb'.freeze, &:read) }
    let(:response) { double('...', parsed_response: contents) }

    before { allow(HTTParty).to receive(:get).and_return(response) }

    context 'when file exists' do
      it 'should not download the file' do
        allow(File).to receive_messages(file?: true)
        expect(HTTParty).to_not receive(:get)
        uut.public_send(mut, remote_file, dest_file)
      end
    end

    context 'when file does not exist' do
      before { FileUtils.rm dest_file if File.file? dest_file }

      describe HTTParty do
        it 'should make a call to get' do
          expect(HTTParty).to receive(:get).with(remote_file).once
          uut.public_send(mut, remote_file, dest_file)
        end
      end

      describe "#{HTTParty} response" do
        it 'should make a call to parsed_response' do
          expect(response).to receive(:parsed_response).once
          uut.public_send(mut, remote_file, dest_file)
        end
      end

      it 'should download the file' do
        uut.public_send(mut, remote_file, dest_file)
        expect(FileUtils.compare_file(bin_file, dest_file)).to eq true
      end
    end
  end
end
