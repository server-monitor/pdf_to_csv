
# Usage:
#   view=/path/to/this/file.rb \
#   remote_file=http://path/to/spreadsheet.pdf \
#   bundle exec bin/app

module View
  SHOW_UP_TO_IX = -1
  private_constant :SHOW_UP_TO_IX

  FIELD = Struct.new(
    :name, :address, :city, :zip, :incentive
  ).new(
    *[
      [0, 15],
      [1, 20],
      [2, 20],
      [3, 20],
      [4, 40]
    ].map do |field|
      Struct.new(:ix, :max_line_length).new(field[0], field[1])
    end
  ).freeze
  private_constant :FIELD

  SHOW_FIELDS = [
    :name,
    :address,
    :city,
    :zip,
    :incentive
  ].freeze
  private_constant :SHOW_FIELDS

  SHOW_FIELDS_IX = SHOW_FIELDS.map { |key| FIELD.public_send(key).ix }.freeze
  private_constant :SHOW_FIELDS_IX

  HEADINGS_ROW_IX = 0
  private_constant :HEADINGS_ROW_IX

  DATA_ROW_START_IX = 1
  private_constant :DATA_ROW_START_IX

  def show(csv_file)
    csv = CSV.read csv_file

    table = build_table(csv)

    puts Terminal::Table.new table
    puts
    data_rows_count = table.fetch(:rows).count
    puts "Table data rows count: #{data_rows_count}"
    all = csv[DATA_ROW_START_IX..-1].count
    puts "All CSV rows count: #{all}"
  end

  private

  def build_table(csv)
    headings = SHOW_FIELDS_IX.map { |ix| csv[HEADINGS_ROW_IX][ix] }
    rows = csv[DATA_ROW_START_IX..SHOW_UP_TO_IX].map do |row|
      SHOW_FIELDS.map { |field_key| trim row, field_key }
    end

    return { headings: headings, rows: rows }
  end

  NIL = 'NIL'.freeze
  private_constant :NIL

  def trim(row, field_key)
    field = FIELD.public_send field_key

    field_value = row[field.ix]
    return NIL if field_value.nil?

    max_line_length = field.max_line_length
    return field_value if !max_line_length

    return (
      if field_value.size > max_line_length
        field_value[0..max_line_length] + '...'
      else
        field_value
      end
    )
  end
end
