# The Consumer

The Consumer interacts with the Provider by 'consumer-driven' design, meaning that the Consumer sets expectations up front.
This is done by creating a contract that represents the Consumer's interaction with the Provider for any calls it may wish to make to it.

Keeping it simple, our example is an application called Zoo App, that displays animal information to its customer, based on information given by the Provider.
The Consumer maintains an Animal model, and delegates actions to a AnimalServiceClient to interact with the Provider.  

# An integration test

Pact contracts are created during unit test execution. In this example, we'll use rSpec. Without any Contract additions, the test looks like this:

```ruby
describe 'example' do
  ...

  it 'returns an alligator' do
    alligator = subject.get_alligator(1)
    expect(alligator.name).not_to be_nil
    expect(alligator.age).not_to be_nil
  end
end

```
In the test environment, we make sure that an Alligator with id 1 exists in the Provider's database, and the test expects to receive it as the result of get_alligator.

Here's the implementation of get_alligator:

```ruby
  def get_alligator id

    response = self.class.get("/alligator/#{id}")
    unless response.nil?
      Alligator.new(JSON.parse(response.body)['name'])
    end

  end
```
If we were to run this test as is, it would be an integration test, as we're making an actual HTTP GET call to the Provider's /alligator endpoint.

# A mocked integration test

Before executing integration tests, we are interested in creating and validating the contract with the Provider. With modification to the rSpec test, we bring-in Pact to do this work for us.

Here's how:
```ruby
  ...
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
```
The flow should be familiar to those versed in the 'given/when/then' manner of testing. Here it's 'given/upon_receiving/with/will_respond'.
We're saying that we expect GET /alligator to return a 200 with a body describing an animal with any string as its name, and any number as it's age.
By using the Pact.like matcher, we're ignoring the actual name and age, and we're specifying the structure (name, age) and their respective types (string, integer) 

Here's the full test:

```ruby
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

```

When running this test, Pact will create the contract, that contains the information it needs to later validate that it's upheld by the Provider.

# Summary

Given a contract in hand, the developers of the Consumer code can continue to add cases, such as usage of additional endpoints and error conditions.
A bonus using this mocked system is that the developers of the Provider code can also continue their implementation in parallel without holding up the Consumer team.

# Next step

Let's see how to implement the Provider and ensure that it satisfies the contract created by the Consumer.

# The Provider

The provider in our example is a Sinatra app that answers to GET /alligator and /crocodile. It's expects an id by which to retrieve the data from a local database it maintains.
Nothing special, nor any special code to accommodate Pact in any way.

This is an example of the GET /alligator:

```ruby
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
```

As you can see, it returns its shaped version of the Alligator object to contain only name and age, as per the Pact. Again as per spec, it returns an empty body and 404 if the alligator was not found.
So how does the contract testing work for the cases when we have an alligator and when it's not found? This is when...

# Pact Magic Happens

When we run 'rake pact:verify', Pact runs interference, and sets up states to simulate the different use cases we're intersted in; in our case, one when the alligator exists, and the other when it does not.

Here are the two states in Pact syntax:

```ruby
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
```

The states 'an alligator exists' and 'an alligator is not found' coincide with the values used in the Consumer's rSpec file described above.
In the first case, we add an alligator with the id 1 to the database, in the second one, none is added. The data either present or missing in the database will control whether we return an Alligator or a 404.

So, simply by using Pact, we're able to change the behaviour of the server without changing its implementation. Let's call it "just in time mocking".

# Placing the contract to be used by both Consumer and Producer

In order for the whole thing to work, we need to run a Pact Broker. In this article, we use one in a Docker image, that you can reference in the source code.

Once the Consumer is happy with the contract, it publishes it to the Broker thus:
```ruby
path = "/pacts/provider/Animal%20Service/consumer/Zoo%20App/version/#{CONTRACT_VERSION}"
req = Net::HTTP::Put.new(path, { 'Content-Type' => 'application/json' })
req.body = IO.read('./spec/pacts/zoo_app-animal_service.json')
response = Net::HTTP.new('localhost', 9292).start { |http| http.request(req) }
```

Giving it an ID (CONTRACT_VERSION), it posts the data to the Broker, in our instance it's localhost:9292.

The Provider will access this location when `rake pact:verify` is called, and the Broker will fail the verification if the contract is not adhered to.

# What's the workflow?

- Consumer and Publisher teams sit and work together to define the structure and semantics of the data that they intend to exchange.
- Consumer codifies this into an integration test incorporating the Pact framework, which creates a Contract
- Consumer publishes the Contract to the Broker
- Consumer's CI makes sure pact:verify works with each merge
- Provider's CI runs pact:verify works with each merge

This cycle ensures that both Consumer and Provider did not break the Contract due to:
- Different expectations from the Consumer
- Different responses from the Provider

Thus, both teams will be well poised for integration tests when the time comes (in the pyramid: unit -> contract -> integration and beyond).

Access the code accompanying this article on my [github](https://github.com/ihassin/ihassin-pact-ruby-example).

Read all about it at the [Pact website](https://docs.pact.io/implementation_guides/ruby/readme).

Happy coding!

