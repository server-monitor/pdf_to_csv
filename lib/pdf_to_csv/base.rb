
require 'open3'
require 'pathname'
require 'fileutils'

module PDFToCSV
  DIR = Pathname.new('./'.freeze).freeze

  # DOTS = Array.new(3).map { '..'.freeze }
  # private_constant :DOTS

  # DIR = Pathname.new(
  #   File.expand_path(File.join(*DOTS), __FILE__).freeze
  # ).freeze

  DATA_DIR = DIR.join('data'.freeze).freeze

  File.directory?(DATA_DIR) or FileUtils.mkdir(DATA_DIR)

  module Base
    def cmd_exist?(cmd)
      _stdout_str, _stderr_str, _status = Open3.capture3(cmd)
      return true
    rescue Errno::ENOENT => exc
      return false if exc.message == "No such file or directory - #{cmd}"
      raise exc
    end
  end
end
