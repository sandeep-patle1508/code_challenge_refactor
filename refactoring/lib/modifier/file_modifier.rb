## input:
#   - file match string, sale_amount_factor and cancellation_factor
#   - get the latest file from array of files matched by given string
#   - sort the file rows by 'Clicks' column and modify the row values
# output:
#   - create a sort and modified file

class FileModifier
  # monkey-patch Float and String class
  Float.include CoreExtensions::Float
  String.include CoreExtensions::String
  # include constant
  include Modifier::Constant

  def initialize(input_file, sale_amount_factor, cancellation_factor)
    @input_file = input_file
    @sale_amount_factor = sale_amount_factor
    @cancellation_factor = cancellation_factor
  end

  # sort file by clicks column and generate a new file.
  # modify the values of sorted file.
  # write to output file.
  def modify
    sorted_file_enum = FileManager.new(@input_file).sort('Clicks')
    modified_rows_enum = read_and_modify_rows(sorted_file_enum)
    generate_output_files(modified_rows_enum)
  end

  private

  # write modified rows into new file.
  def generate_output_files(rows_enum)
    done = false
    file_index = 0
    file_name = @input_file.gsub('.txt', '')

    while not done do
      CSV.open(file_name + "_#{file_index}.txt", 'wb', EXTENDED_CSV_OPTIONS) do |csv|
        # insert header row
        begin
          row = rows_enum.peek
          csv << row.headers
        rescue StopIteration
          break
          done = true
        end

        line_count = 1
        while line_count < LINES_PER_FILE
          begin
            csv << rows_enum.next
            line_count +=1
          rescue StopIteration
            done = true
            break
          end
        end
        file_index += 1
      end
    end
  end

  # modify values.
  def modify_values(row)
    LAST_REAL_VALUE_WINS.each do |key|
      value = row[key]
      row[key] = (value.nil? or value.to_s == '0' or value == '') ? nil : value
    end

    INT_VALUES.each { |key| row[key] = row[key].to_s }

    FLOAT_VALUES.each { |key| row[key] = row[key].from_german_to_f.to_german_s }

    COMMISSIONS.each do |key|
      row[key] = (@cancellation_factor * row[key].from_german_to_f).to_german_s
    end

    COMMISSIONS_VALUES.each do |key|
      row[key] = (@cancellation_factor * @sale_amount_factor *
        row[key].from_german_to_f).to_german_s
    end

    row
  end

  # lazy read and modify row values.
  def read_and_modify_rows(file)
    Enumerator.new do |yielder|
      CSV.foreach(file, DEFAULT_CSV_OPTIONS) do |row|
        yielder.yield(modify_values(row))
      end
    end
  end
end
