# Module to money patch a method into String class to convert string into germany format float value
module CoreExtensions
  module String
    def from_german_to_f
  		gsub(',', '.').to_f
  	end
  end
end
