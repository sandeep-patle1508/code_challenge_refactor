require_relative 'lib/modifier/file_modifier'

latest_file = FileManager.new('project_2012-07-27_2012-10-10_performancedata').latest
FileModifier.new(latest_file, 1, 0.4).modify

puts 'DONE modifying'
