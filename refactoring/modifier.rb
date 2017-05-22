require_relative 'lib/core_extensions/float'
require_relative 'lib/core_extensions/string'
require_relative 'lib/modifier/constant'
require_relative 'lib/file_manager'
require_relative 'lib/modifier/file_modifier'
require 'csv'
require 'date'

latest_file = FileManager.new('project_2012-07-27_2012-10-10_performancedata').latest
FileModifier.new(latest_file, 1, 0.4).modify

puts 'DONE modifying'
