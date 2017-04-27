
require 'open3'

require_relative './downloader'
require_relative './java'
require_relative './log'

module PDFToCSV
  class PDF
    include Log

    attr_reader :file

    def initialize(remote_file, file, downloader: nil)
      @remote_file = remote_file
      @file = file
      @fetcher = downloader || Downloader.new
    end

    def download
      fetcher.download remote_file, file
      return self
    end

    def to_csv(dest_file)
      gray "Converting '#{file}' ...".freeze, "To '#{dest_file}'".freeze

      if File.file? dest_file
        warning 'Dest file already exists', indent: true
        return self
      end

      stdout_str, stderr_str, status = Open3.capture3(
        Java::CMD,
        '-jar'.freeze, Java::Jar::TABULA_LOCAL,
        '--pages'.freeze, 'all'.freeze,
        file
      )

      raise 'Did not exit' if !status.exited?
      raise stderr_str if !status.success?

      if stderr_str
        sanitized_err = stderr_str.strip
        error sanitized_err if !sanitized_err.empty?
      end

      open dest_file, 'wb' do |file|
        file.write stdout_str
      end

      ok

      return self
    end

    private

    attr_reader :remote_file, :fetcher
  end
end
