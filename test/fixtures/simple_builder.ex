defmodule FixtureBuilder.Test.Fixtures.SimpleBuilder do
  use FixtureBuilder.Fixtures

  def build(:simple_atom, _, _), do: :simple_atom

  def build(:custom_value, %{value: value}, _), do: value
  def build(:custom_value, _, _), do: "hello world"

  def build(:atom, _, _), do: :some_atom
  def build(:simple_map, _, _), do: %{a: "hello", b: "world"}
end
