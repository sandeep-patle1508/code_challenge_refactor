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
    input_file = FileUtils.new(input_file).sort('Clicks')
    input_enumerator = lazy_read(input_file)

    merger = Enumerator.new do |yielder|
      while true
        begin
          row = input_enumerator.next
          row_hash = row_to_hash(row)
          yielder.yield(modify_values(row_hash))
        rescue StopIteration
          break
        end
      end
    end

    done = false
    file_index = 0
    file_name = output_file.gsub('.txt', '')
    while not done do
      CSV.open("modifiertest_#{file_index}.txt", 'wb', EXTENDED_CSV_OPTIONS) do |csv|
        headers_written = false
        line_count = 0
        while line_count < LINES_PER_FILE
          begin
            merged = merger.next
            if not headers_written
              csv << merged.keys
              headers_written = true
              line_count +=1
            end
            csv << merged
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

  def modify_values(hash)
    LAST_REAL_VALUE_WINS.each do |key|
      value = hash[key]
      hash[key] = (value.nil? or value.to_s == '0' or value == '') ? nil : value
    end
    INT_VALUES.each do |key|
      hash[key] = hash[key].to_s
    end
    FLOAT_VALUES.each do |key|
      hash[key] = hash[key].from_german_to_f.to_german_s
    end
    COMMISSIONS.each do |key|
      hash[key] = (@cancellation_factor * hash[key].from_german_to_f).to_german_s
    end
    COMMISSIONS_VALUES.each do |key|
      hash[key] = (@cancellation_factor * @saleamount_factor * hash[key].from_german_to_f).to_german_s
    end
    hash
  end

  def row_to_hash(row)
    result = {}
    row.headers.each do |key|
      result[key] = row.nil? ? nil : row[key]
    end
    result
  end

  def lazy_read(file)
    Enumerator.new do |yielder|
      CSV.foreach(file, DEFAULT_CSV_OPTIONS) do |row|
        yielder.yield(row)
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
