# frozen_string_literal: true

require 'active_record'
require 'yaml'

Pact.set_up do
  db = SQLite3::Database.new('./test_data.sqlite3')
  db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS animals (
    id INTEGER PRIMARY KEY,
    name TEXT,
    age INTEGER
  );
SQL
end

Pact.tear_down do
  db = SQLite3::Database.new('./test_data.sqlite3')
  db.execute <<-SQL
    drop table animals;
  SQL
end

Pact.provider_states_for 'Zoo App' do
  provider_state 'an alligator exists' do
    set_up do
      add_alligator(1)
    end

    tear_down do
    end
  end

  provider_state 'an alligator is not found' do
    no_op
  end

  provider_state 'an error occurs while retrieving a crocodile' do
    no_op
  end

end

def add_alligator(number)
  db = SQLite3::Database.new('./test_data.sqlite3')
  db.execute 'INSERT INTO animals (id, name, age) VALUES (?, ?, ?)', [number, 'Alice', 30]
end
