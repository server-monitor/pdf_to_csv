
require 'httparty'

require_relative './log'

module PDFToCSV
  class Downloader
    include Log

    def initialize(log: true)
      @log = log
    end

    def download(remote_file, dest_file)
      if log
        gray(
          "Downloading '#{remote_file}' ...".freeze, "To '#{dest_file}'".freeze
        )
      end

      if File.file? dest_file
        warning 'Dest file already exists', indent: true if log
        return
      end

      parsed_response = HTTParty.get(remote_file).parsed_response

      File.open(dest_file, 'wb') do |file|
        file.write parsed_response
      end

      ok if log
    end

    private

    attr_reader :log, :log_to_stderr
  end
end
