require 'co2mini'

dev = CO2mini.new

puts dev.read_once(:co2)
puts dev.read_once(:temp)

