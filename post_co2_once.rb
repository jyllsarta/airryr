require_relative './co2mini_mock.rb'
require 'dotenv/load'
require 'net/https'
require "json"

dev = CO2miniMock.new # TODO: Mockかどうかは ENV で分岐させたい
co2 =  dev.read_once(:co2)
temp = dev.read_once(:temp)
now = Time.now.to_i

uri = URI.parse("https://api.mackerelio.com/api/v0/services/#{ENV["MACKEREL_SERVICE_NAME"]}/tsdb")
params = [
           {name: "AirCondition.CO2", time: now, value: co2},
           {name: "AirCondition.Temperature", time: now, value: temp}
         ]
header = {'X-Api-Key': ENV["MACKEREL_API_KEY"], 'Content-Type': 'application/json'}

response = Net::HTTP.post(uri, JSON.dump(params), header)
puts "status code:#{response.code} / body:#{response.body}"
