defmodule FixtureBuilder.Test.Fixtures.ComplexBuilder do
  alias FixtureBuilder.Test.Fixtures

  use FixtureBuilder.Fixtures

  require ExUnit.Assertions

  import FixtureBuilder.Test.Fixtures
  import ExUnit.Assertions

  def build(:map_comp, args, %FixtureBuilder{} = _fixtures) do
    value = Map.get(args, :value, :map_comp)

    Fixtures.new([
      put(:a, :custom_value, %{value: value}),
      put(:b, :custom_value, %{value: value})
    ])
  end

  def build(:list_comp, args, %FixtureBuilder{} = _fixtures) do
    value = Map.get(args, :value, :list_comp)

    Fixtures.new([], %{}, [
      append(:custom_value, %{value: value}),
      append(:custom_value, %{value: value})
    ])
  end

  def build(:assert_parent_is_map, _, %FixtureBuilder{parent: parent}) do
    assert parent == %{hello: "world"}
    %{asserted_map: true}
  end

  def build(:data, %{key: key}, %FixtureBuilder{data: data}) do
    Map.get(data, key)
  end
end
