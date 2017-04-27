
require 'pathname'

APP_CONSTANT = :PDFToCSV
SPEC_DIR = Pathname.new(File.dirname(__FILE__)).freeze
SPEC_DATA_DIR = SPEC_DIR.join('data'.freeze)

class TargetFile
  DOTS = Array.new(2).map { '..'.freeze }
  APP_NAME = File.basename(
    File.expand_path(File.join(*DOTS), __FILE__).freeze
  ).freeze

  SPEC_APP_DIR_REGEXP = Regexp.new(
    Regexp.escape(File.join(SPEC_DIR.to_s, 'app'))
  )

  private_constant :DOTS
  private_constant :APP_NAME
  private_constant :SPEC_APP_DIR_REGEXP

  LIB_APP_DIR = File.join '..'.freeze, 'lib'.freeze, APP_NAME

  def setup(caller_file = nil)
    caller_file ||= caller.first.split(':').first

    target_file = File.join(
      LIB_APP_DIR,
      caller_file.sub(SPEC_APP_DIR_REGEXP, '').sub(/_spec[.]rb \z/x, '.rb')
    )

    require_relative target_file
    Object.class_eval { include Object.const_get APP_CONSTANT }
  end
end
