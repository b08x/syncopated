#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'net/http'
require 'json'

today = Date.today
first_day_of_current_month = today - today.mday + 1
first_day_of_next_month = (first_day_of_current_month >> 1)
first_day_of_current_month_str = first_day_of_current_month.strftime('%Y-%m-%d')
first_day_of_next_month_str = first_day_of_next_month.strftime('%Y-%m-%d')

API_KEY = ENV['OPENAI_API_KEY']
ORG_ID = ENV['OPENAI_ORG_ID']
USER_ID = "user-8cuUzZzC6uwK2TpQyqhxtpeR"
API_BASE_URL = "https://api.openai.com/v1/organizations/#{ORG_ID}/users"
API_USAGE_URL = "https://api.openai.com/v1/usage?date=#{today}&end_date=#{first_day_of_next_month}&start_date=#{first_day_of_current_month}&user_public_id=#{USER_ID}"

def fetch_openapi_usage_statistics
  usage_url = API_USAGE_URL
  uri = URI(usage_url)
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "Bearer #{API_KEY}"
  req['pathj']

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
    http.request(req)
  }

  p JSON.parse(res.body)["data"][0]
  exit

  if res.code == '200'
    raw_usage_value = JSON.parse(res.body)['total_usage']
    dollars = raw_usage_value / 100.0
    dollars_rounded = dollars.round(2)
    return dollars_rounded
  else
    puts "Error fetching OpenAPI usage statistics: #{res.code} - #{res.body}"
    return nil
  end
end

# begin
#   puts fetch_openapi_usage_statistics
# rescue StandardError => e
#   puts "error"
# end

puts "7.01"
