# Module to Money patch a method into float class to convert float value into germany format string
module CoreExtensions
  module Float
    def to_german_s
  		self.to_s.gsub('.', ',')
  	end
  end
end
