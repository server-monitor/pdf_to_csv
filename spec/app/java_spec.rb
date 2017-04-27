
# rubocop:disable Metrics/BlockLength

require 'httparty'
require 'fileutils'

TargetFile.new.setup

RSpec.describe Java do
  exist_method = :exist?

  it { should respond_to exist_method }

  describe exist_method do
    subject { Java.new }

    context 'when command does not exist' do
      before do
        allow(subject).to receive_messages(cmd_exist?: false)
      end

      it 'should raise error' do
        expect do
          subject.public_send(exist_method)
        end.to raise_error RuntimeError, /java cmd must exist/
      end
    end

    context 'when command exists' do
      it 'should not raise error' do
        expect do
          subject.public_send(exist_method)
        end.to_not raise_error
      end
    end
  end

  jar_attr = :jar

  it { should respond_to jar_attr }

  describe jar_attr do
    subject { Java.new.jar }

    it { should respond_to exist_method }
  end
end

RSpec.describe Java::Jar do
  let(:instance) { Java::Jar.new }

  exist_method = :exist?

  it { should respond_to exist_method }

  describe exist_method do
    subject { instance.public_send(exist_method) }

    [false, true].each do |cond|
      context "when jar file exists? => '#{cond}'" do
        before { allow(File).to receive(:file?).and_return(cond) }
        it { should eq cond }
      end
    end
  end

  download_method = :download

  it { should respond_to download_method }

  describe download_method do
    let(:tabula_version) { '0.9.2'.freeze }
    let(:tabula_bname) do
      "tabula-#{tabula_version}-jar-with-dependencies.jar".freeze
    end

    let(:remote_file) do
      [
        'https://github.com/tabulapdf/tabula-java/releases/download/'.freeze,
        tabula_version,
        tabula_bname
      ].join('/'.freeze)
    end

    let(:bin_file) { SPEC_DATA_DIR.join(tabula_bname.freeze).freeze }
    let(:contents) { open(bin_file, 'rb'.freeze, &:read) }
    let(:response) { double('...', parsed_response: contents) }

    before { allow(HTTParty).to receive(:get).and_return(response) }

    let(:uut) { instance.public_send download_method }

    context 'when file exists' do
      it 'should not download the file' do
        allow(File).to receive_messages(file?: true)
        expect(HTTParty).to_not receive(:get)
        uut
      end
    end

    context 'when file does not exist' do
      before do
        allow(File).to receive_messages(file?: false)

        # Don't create any files
        allow(FileUtils).to receive(:mkdir_p)
        allow(File).to receive(:open)
      end

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
            Java::Jar.new(downloader: fetcher).public_send(
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
        dest_file = '/tmp/dummy_java_tabula.jar'
        allow(File).to receive(:open) { IO.write(dest_file, contents) }
        uut

        expect(system('diff', bin_file.to_s, dest_file)).to eq true

        # # I have no idea why this returns some number instead of true.
        # expect(
        #   FileUtils.compare_file(bin_file.to_s, bin_file.to_s)
        # ).to eq true
      end

      describe 'other mocks' do
        describe FileUtils do
          it 'should make call to mkdir_p =< 1' do
            expect(FileUtils).to receive(:mkdir_p).at_most(1)
            uut
          end
        end

        describe File do
          it 'should receive open once' do
            expect(File).to receive(:open).once
            uut
          end
        end
      end
    end
  end
end
