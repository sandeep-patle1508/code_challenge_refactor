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

		combiner = Combiner.new do |value|
			value[KEYWORD_UNIQUE_ID]
		end.combine(input_enumerator)

		merger = Enumerator.new do |yielder|
			while true
				begin
					list_of_rows = combiner.next
					merged = combine_hashes(list_of_rows)
					yielder.yield(combine_values(merged))
				rescue StopIteration
					break
				end
			end
		end

		done = false
		file_index = 0
		file_name = output.gsub('.txt', '')
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

	def combine_values(hash)
		LAST_VALUE_WINS.each do |key|
			hash[key] = hash[key].last
		end
		LAST_REAL_VALUE_WINS.each do |key|
			hash[key] = hash[key].select {|v| not (v.nil? or v == 0 or v == '0' or v == '')}.last
		end
		INT_VALUES.each do |key|
			hash[key] = hash[key][0].to_s
		end
		FLOAT_VALUES.each do |key|
			hash[key] = hash[key][0].from_german_to_f.to_german_s
		end
		COMMISSIONS.each do |key|
			hash[key] = (@cancellation_factor * hash[key][0].from_german_to_f).to_german_s
		end
		COMMISSIONS_VALUES.each do |key|
			hash[key] = (@cancellation_factor * @saleamount_factor * hash[key][0].from_german_to_f).to_german_s
		end
		hash
	end

	def combine_hashes(list_of_rows)
		keys = []
		list_of_rows.each do |row|
			next if row.nil?
			row.headers.each do |key|
				keys << key
			end
		end
		result = {}
		keys.each do |key|
			result[key] = []
			list_of_rows.each do |row|
				result[key] << (row.nil? ? nil : row[key])
			end
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

modified = input = latest('project_2012-07-27_2012-10-10_performancedata')
modification_factor = 1
cancellaction_factor = 0.4
modifier = Modifier.new(modification_factor, cancellaction_factor)
modifier.modify(modified, input)

puts 'DONE modifying'
