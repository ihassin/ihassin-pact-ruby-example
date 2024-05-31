class Alligator
  attr_reader :name, :age

  def initialize (name:, age:)
    @name = name
    @age = age
  end

  def == (other)
    other.is_a?(Alligator) && other.name == name
  end
end
