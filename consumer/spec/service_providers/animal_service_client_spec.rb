# frozen_string_literal: true

require_relative './pact_helper'
require_relative '../../services/animal_service_client'

describe AnimalServiceClient, pact: true do
  before do
    AnimalServiceClient.base_uri 'localhost:1234'
  end

  subject { AnimalServiceClient.new }

  describe 'get_alligator' do
    context 'when an alligator exists' do
      before do
        # noinspection RubyResolve
        animal_service
          .given('an alligator exists')
          .upon_receiving('a request for an alligator')
          .with(method: :get, path: '/alligator/1', query: '')
          .will_respond_with(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: Pact.like(
              name: 'Any name',
              age: 36
            )
          )
      end

      it 'returns an alligator' do
        alligator = subject.get_alligator(1)
        expect(alligator.name).not_to be_nil
        expect(alligator.age).not_to be_nil
      end
    end

    context 'when an alligator is not found' do
      before do
        # noinspection RubyResolve
        animal_service
          .given('an alligator is not found')
          .upon_receiving('a request for an alligator')
          .with(method: :get, path: '/alligator/2', query: '')
          .will_respond_with(
            status: 404,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns nil' do
        response = subject.get_alligator(2)
        expect(response.nil?)
      end
    end
  end

  describe 'get_crocodile' do
    context 'when an error occurs retrieving a crocodile' do
      before do
        # noinspection RubyResolve
        animal_service
          .given('an error occurs while retrieving a crocodile')
          .upon_receiving('a request for a crocodile')
          .with(method: :get, path: '/crocodile', query: '')
          .will_respond_with(
            status: 500,
            headers: { 'Content-Type' => 'application/json' },
            body: { message: 'An error occurred!' }
          )
      end

      it 'raises an error' do
        expect { subject.get_crocodile }.to raise_error 'An error occurred!'
      end
    end
  end

end
