# frozen_string_literal: true

require 'net/http'
require_relative './contract_info'

path = "/pacts/provider/Animal%20Service/consumer/Zoo%20App/version/#{CONTRACT_VERSION}"
req = Net::HTTP::Put.new(path, { 'Content-Type' => 'application/json' })
req.body = IO.read('./spec/pacts/zoo_app-animal_service.json')
response = Net::HTTP.new('localhost', 9292).start { |http| http.request(req) }
puts response.code
