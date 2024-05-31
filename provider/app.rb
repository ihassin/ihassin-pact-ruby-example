# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'sqlite3'
require_relative './models/alligator'

class MyApp < Sinatra::Base
  get '/alligator/:id' do
    content_type :json

    db = SQLite3::Database.new('./test_data.sqlite3')
    query = 'SELECT * FROM animals WHERE id = ?;'
    id = params[:id].to_i
    alligator = db.get_first_row query, id
    if alligator
      alligator = Alligator.new(name: alligator[1], age: alligator[2])
      alligator.to_json
    else
      error 404
    end
  end

  get '/crocodile' do
    content_type :json
    halt 500, {
      message: 'An error occurred!'
    }.to_json
  end
end
