
require 'fileutils'

require_relative './base'
require_relative './downloader'
require_relative './log'

module PDFToCSV
  class Java
    include Base

    attr_reader :jar

    CMD = 'java'.freeze

    def initialize
      @jar = Jar.new
    end

    def exist?
      raise "#{CMD} cmd must exist" if !cmd_exist? CMD
    end

    class Jar
      include Log

      TABULA_VERSION = '0.9.2'.freeze
      TABULA_BNAME = "tabula-#{TABULA_VERSION}-jar-with-dependencies.jar".freeze

      TABULA_REMOTE = [
        'https://github.com/tabulapdf/tabula-java/releases/download/'.freeze,
        TABULA_VERSION,
        TABULA_BNAME
      ].join('/'.freeze).freeze

      JAVA_DIR = DIR.join('java'.freeze).freeze

      TABULA_LOCAL = JAVA_DIR.join(TABULA_BNAME).to_s.freeze

      private_constant :TABULA_VERSION
      private_constant :TABULA_BNAME
      private_constant :TABULA_REMOTE
      private_constant :JAVA_DIR

      def initialize(downloader: nil)
        @fetcher = downloader || Downloader.new(log: false)
      end

      def exist?
        return true if File.file? TABULA_LOCAL
        return false
      end

      def download(force: false)
        return self if exist? and !force

        FileUtils.mkdir_p JAVA_DIR if !File.directory? JAVA_DIR

        info(
          "Downloading '#{TABULA_REMOTE}' ...".freeze,
          "To '#{TABULA_LOCAL}'".freeze
        )
        fetcher.download TABULA_REMOTE, TABULA_LOCAL
        ok
        return self
      end

      private

      attr_reader :fetcher
    end
  end
end
