# input:
#   - filename
# output:
#   - latest: get latest file on the basis of date from a folder
#   - sort: sort rows  by given key and write output into a new file

class FileManager
  # options for file read/write
  DEFAULT_CSV_OPTIONS = { col_sep: "\t", headers: :first_row }
  EXTENDED_CSV_OPTIONS = DEFAULT_CSV_OPTIONS.merge({ :row_sep => "\r\n" })

  def initialize(file)
    @file = file
  end

  # sort rows by given key and write output into a new file.
  def sort key
    output = "#{@file}.sorted"

    content_as_table = CSV.read(@file, DEFAULT_CSV_OPTIONS)
    headers = content_as_table.headers
    index_of_key = headers.index(key)

    content = content_as_table.sort_by { |a| -a[index_of_key].to_i }
    write(content, headers, output)

    output
  end

  # get latest file on the basis of date from a folder.
  def latest
    files = Dir["#{ ENV['HOME'] }/workspace/*#{@file}*.txt"]

    throw RuntimeError if files.empty?

    files.sort_by! do |file|
      last_date = /\d+-\d+-\d+_[[:alpha:]]+\.txt$/.match file
      last_date = last_date.to_s.match /\d+-\d+-\d+/
      DateTime.parse(last_date.to_s)
    end

    files.last
  end

  private

  # create new file as per given header and content
  def write(content, headers, output)
    CSV.open(output, 'wb', EXTENDED_CSV_OPTIONS) do |csv|
      csv << headers

      content.each do |row|
        csv << row
      end
    end
  end
end
