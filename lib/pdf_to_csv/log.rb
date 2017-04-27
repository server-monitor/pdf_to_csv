
require 'paint'

module PDFToCSV
  module Log
    INDENT = (' ' * 2).freeze
    private_constant :INDENT

    OUTPUT_TO_STDERR = true
    private_constant :OUTPUT_TO_STDERR

    def gray(*messages, chomp: false, indent: false, stderr: OUTPUT_TO_STDERR)
      str = join_messages messages

      output(
        Paint[str, '#BEBEBE'.freeze],
        chomp: chomp, indent: indent, stderr: stderr
      )
    end

    def info(
      *messages,
      chomp: false, indent: false, bold: false, stderr: OUTPUT_TO_STDERR
    )
      str = join_messages messages
      output(
        Paint[str, *paint_spec(:default, bold: bold)].freeze,
        chomp: chomp, indent: indent, stderr: stderr
      )
    end

    def warning(
      *messages, chomp: false, indent: false, stdout: false
    )
      str = join_messages messages
      output(
        Paint[str, :yellow, :bold].freeze,
        chomp: chomp, indent: indent, stderr: !stdout
      )
    end

    def new_line
      output ''.freeze
    end

    def ok(chomp: false, indent: true, stderr: OUTPUT_TO_STDERR)
      output(
        Paint['OK'.freeze, :green].freeze,
        chomp: chomp, indent: indent, stderr: stderr
      )
    end

    def error(
      *messages, chomp: false, indent: false, raise_error: false
    )
      str = join_messages messages
      output(
        Paint[str, :red, :bold].freeze,
        chomp: chomp, indent: indent, stderr: true
      )
      raise if raise_error
    end

    private

    def paint_spec(*spec, bold: false)
      return spec if !bold
      return spec + [:bold]
    end

    def join_messages(messages)
      return ''.freeze if !messages || messages.count.zero?
      first = messages[0]
      return first if messages.count == 1
      return [
        messages[0], messages[1..-1].map { |msg| insert_indent msg }
      ].join("\n")
    end

    def insert_indent(str)
      INDENT + str.to_s
    end

    def test?
      $PROGRAM_NAME =~ %r{/bin/rspec}
    end

    def output(input_str, chomp: false, indent: false, stderr: false)
      str = indent ? insert_indent(input_str) : input_str
      return str if test?
      meth = chomp ? :print : :puts

      channel = stderr ? $stderr : $stdout

      channel.public_send meth, str

      # Kernel.public_send meth, str
      return str
    end
  end
end
