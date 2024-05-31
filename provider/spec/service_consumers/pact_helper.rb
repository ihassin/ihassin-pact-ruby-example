# frozen_string_literal: true

require 'pact/provider/rspec'
require_relative 'states'
require_relative '../../app'
require_relative './contract_info'

Pact.configure do | config |
  config.diff_formatter = :embedded
end

Pact.service_provider 'Animal Service' do
  publish_verification_results true
  app_version ENV['GIT_COMMIT'] || `git rev-parse --verify HEAD`.strip
  honours_pact_with 'Zoo App' do
    pact_uri "http://localhost:9292/pacts/provider/Animal%20Service/consumer/Zoo%20App/version/#{SERVICE_CONTRACT_VERSION}"
  end
end

RSpec.configure do |config|
  config.before :suite do
    @server_thread = Thread.new do
      Rack::Handler::WEBrick.run Sinatra::Application, Port: 4567
    end
    sleep 1 # give the server time to start
  end

  config.after :suite do
    # @server_thread.kill
  end
end
