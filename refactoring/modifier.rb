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

  def initialize(saleamount_factor, cancellation_factor)
    @saleamount_factor = saleamount_factor
    @cancellation_factor = cancellation_factor
  end

  def modify(output_file, input_file)
    # sort file by clicks column value
    sorted_file = FileUtils.new(input_file).sort('Clicks')
    # lazy read and modify values
    modified_rows = read_modify_rows(sorted_file)

    done = false
    file_index = 0
    file_name = output_file.gsub('.txt', '')
    while not done do
      CSV.open(file_name + "_#{file_index}.txt", 'wb', EXTENDED_CSV_OPTIONS) do |csv|
        headers_written = false
        line_count = 0
        while line_count < LINES_PER_FILE
          begin
            row_hash = modified_rows.next
            if not headers_written
              csv << row_hash.headers
              headers_written = true
              line_count +=1
            end
            csv << row_hash
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

  private

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
      row[key] = (@cancellation_factor * @saleamount_factor * row[key].from_german_to_f).to_german_s
    end
    row
  end

  def read_modify_rows(file)
    Enumerator.new do |yielder|
      CSV.foreach(file, DEFAULT_CSV_OPTIONS) do |row|
        yielder.yield(modify_values(row))
      end
    end
  end
end

modified = input = FileUtils.new('project_2012-07-27_2012-10-10_performancedata').latest
modification_factor = 1
cancellaction_factor = 0.4
modifier = Modifier.new(modification_factor, cancellaction_factor)
modifier.modify(modified, input)

puts 'DONE modifying'
