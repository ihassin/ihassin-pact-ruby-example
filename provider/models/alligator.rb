class Alligator
  attr_reader :name, :age, :length

  def initialize (name:, age:)
    @name = name
    @age = age
  end

  def == (other)
    other.is_a?(Alligator) && other.name == name
  end

  def to_json(*_args)
    { name: @name, age: @age }.to_json
  end
end
