require 'httparty'
require_relative '../models/alligator'

class AnimalServiceClient
  include HTTParty
  base_uri 'http://animal-service.com'

  def get_alligator id

    response = self.class.get("/alligator/#{id}")
    unless response.nil?
      body = JSON.parse(response.body)
      name = body['name']
      age = body['age']
      Alligator.new(name: name, age: age)
    end

  end

  def get_crocodile
    self.class.get('/crocodile')
    raise StandardError.new('An error occurred!')
  end
end
