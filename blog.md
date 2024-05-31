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

