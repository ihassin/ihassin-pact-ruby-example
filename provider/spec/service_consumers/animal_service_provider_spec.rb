require_relative './pact_helper'

describe 'Animal Service' do
  it 'honours the contract with Animal Consumer' do
    Pact.service_provider 'Animal Service' do
      honours_pact_with 'Animal consumer' do
        # pact_uri '../consumer/spec/pacts/zoo_app-animal_service.json'
        pact_uri 'http://localhost:9292/pacts/provider/Animal%20Service/consumer/Zoo%20App/version'
      end
    end
  end
end
