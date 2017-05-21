require_relative 'lib/combiner'
require_relative 'lib/core_extensions/float'
require_relative 'lib/core_extensions/string'
require_relative 'lib/modifiers/constant'
require_relative 'lib/file_utils'
require 'csv'
require 'date'

class Modifier
  # monkey-patch Float and String
  Float.include CoreExtensions::Float
  String.include CoreExtensions::String
  # include constant
  include Modifiers::Constant

  def initialize(input_file, sale_amount_factor, cancellation_factor)
    @input_file = input_file
    @sale_amount_factor = sale_amount_factor
    @cancellation_factor = cancellation_factor
  end

  def modify
    # sort file by clicks column value
    sorted_file_enum = FileUtils.new(@input_file).sort('Clicks')
    modified_rows_enum = read_modify_rows(sorted_file_enum)
    generate_output_files(modified_rows_enum)
  end

  private
  # write modified rows into new file
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
  # modify values
  def modify_values(row)
    LAST_REAL_VALUE_WINS.each do |key|
      value = row[key]
      row[key] = (value.nil? or value.to_s == '0' or value == '') ? nil : value
    end
    INT_VALUES.each do |key|
      row[key] = row[key].to_s
    end
    FLOAT_VALUES.each do |key|
      row[key] = row[key].from_german_to_f.to_german_s
    end
    COMMISSIONS.each do |key|
      row[key] = (@cancellation_factor * row[key].from_german_to_f).to_german_s
    end
    COMMISSIONS_VALUES.each do |key|
      row[key] = (@cancellation_factor * @sale_amount_factor * row[key].from_german_to_f).to_german_s
    end
    row
  end
  # lazy read and modify values
  def read_modify_rows(file)
    Enumerator.new do |yielder|
      CSV.foreach(file, DEFAULT_CSV_OPTIONS) do |row|
        yielder.yield(modify_values(row))
      end
    end
  end
end

latest_file = FileUtils.new('project_2012-07-27_2012-10-10_performancedata').latest
Modifier.new(latest_file, 1, 0.4).modify

puts 'DONE modifying'
