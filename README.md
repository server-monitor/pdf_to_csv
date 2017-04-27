# PDFToCSV

A simple tool that will download a PDF file containing spreadsheet data then convert it to CSV.

To install, create a directory, `cd` into that directory, then:

`curl https://raw.githubusercontent.com/server-monitor/pdf_to_csv/master/install | bash`

OR

`wget -q -O- https://raw.githubusercontent.com/server-monitor/pdf_to_csv/master/install | bash`

# Usage

`remote_file=http://path/to/spreadsheet.pdf bundle exec bin/app`

This will store the PDF file in `data/file.pdf` and the CSV file in `data/file.csv`.

It won't download the PDF file if the local PDF file exists.

It won't re-create the CSV file if it already exists.

You can pass give it a PDF destination file arg like so:

`dest_file=/path/to/dest.pdf remote_file=http://path/to/spreadsheet.pdf bundle exec bin/app`

The CSV file will be written to `/path/to/dest.csv`.

You can also specify the path to the CSV file by passing `csv_file=/path/to/file.csv` environment variable.

# Example view

`curl https://raw.githubusercontent.com/server-monitor/pdf_to_csv/master/example_view.rb > example_view.rb`

OR

`wget -q -O- https://raw.githubusercontent.com/server-monitor/pdf_to_csv/master/example_view.rb > example_view.rb`

`view=example_view.rb remote_file=http://path/to/spreadsheet.pdf bundle exec bin/app`
