# TODO: mockをロードするかどうかは ENV["TEST"] とかを参照したい
require_relative './co2mini_mock.rb'
require 'co2mini'
require 'dotenv/load'
require 'net/https'
require "json"

class Airrir
  def initialize(watcher_class)
    @watcher = watcher_class.new
    @log_buffer = []
  end

  def post()
    co2 =  @watcher.read_once(:co2)
    temp = @watcher.read_once(:temp)
    now = Time.now.to_i
    params = [
        {name: "AirCondition.CO2", time: now, value: co2},
        {name: "AirCondition.Temperature", time: now, value: temp}
    ]
    send_to_mackerel(params)
  end

  def forever
    @watcher.on(:co2) do |op, value|
      @log_buffer.push({name: "AirCondition.CO2", time: Time.now.to_i, value: value})
      self.push_log
    end
    @watcher.on(:temp) do |op, value|
      @log_buffer.push({name: "AirCondition.Temperature", time: Time.now.to_i, value: value})
      self.push_log
    end
    @watcher.loop
  end

  def push_log
    return unless @log_buffer.first[:time] + ENV["SEND_INTERVAL_SECONDS"].to_i < Time.now.to_i
    params = @log_buffer
    @log_buffer = []
    self.send_to_mackerel(params)
  end

  def send_to_mackerel(params)
    uri = URI.parse("https://api.mackerelio.com/api/v0/services/#{ENV["MACKEREL_SERVICE_NAME"]}/tsdb")
    header = {'X-Api-Key': ENV["MACKEREL_API_KEY"], 'Content-Type': 'application/json'}
    response = Net::HTTP.post(uri, JSON.dump(params), header)
    puts "status code:#{response.code} / body:#{response.body}"
  end
end

# TODO: 起動時に引数とって `bundle exec airrir forever` とかできると便利っぽい
airrir = Airrir.new(CO2mini)
airrir.forever
