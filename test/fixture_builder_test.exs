defmodule FixtureBuilderTest do
  alias FixtureBuilder.Test.Fixtures

  use ExUnit.Case

  import FixtureBuilder.Test.Fixtures

  describe "setup()" do
    test "returns a simple result" do
      assert %{key: :some_atom} = Fixtures.fixtures(put(:key, :atom))
    end
  end

  describe "build()" do
    test "returns a simple result" do
      assert :simple_atom = Fixtures.fixture(:simple_atom)
      assert :simple_atom = Fixtures.fixture(:simple_atom, %{})
    end
  end

  describe "put()" do
    test "puts the result into a simple path" do
      assert %{key: :some_atom} = Fixtures.fixtures(put(:key, :atom))
    end

    test "puts the result into a nested path" do
      assert %{some: ["hello world"]} =
               Fixtures.fixtures([
                 put(:some, :custom_value, %{value: [[]]}),
                 put([:some, 0], :custom_value, %{value: "hello world"})
               ])
    end

    test "sets the parent correctly" do
      assert %{a_key: %{hello: "world", key: %{asserted_map: true}}} =
               Fixtures.fixtures([
                 put(:a_key, :custom_value, %{value: %{hello: "world"}}, [
                   put(:key, :assert_parent_is_map)
                 ])
               ])
    end

    test "supports nested operations" do
      assert %{some: ["hello world"]} =
               Fixtures.fixtures([
                 put(:some, :custom_value, %{value: [[]]}, [
                   put(0, :custom_value, %{value: "hello world"})
                 ])
               ])
    end

    test "supports composition" do
      assert %{comp: %{a: :map_comp, b: :map_comp}} = Fixtures.fixtures(put(:comp, :map_comp))

      assert %{comp: %{a: "hello", b: "hello"}} =
               Fixtures.fixtures([put(:comp, :map_comp, %{value: "hello"})])

      assert %{comp: [:list_comp, :list_comp]} = Fixtures.fixtures(put(:comp, :list_comp))

      assert %{comp: ["world", "world"]} =
               Fixtures.fixtures(put(:comp, :list_comp, %{value: "world"}))
    end

    test "supports composition and nested operations" do
      assert %{comp: %{a: :map_comp, b: :map_comp, hello: "world"}} =
               Fixtures.fixtures([
                 put(:comp, :map_comp, [
                   put(:hello, :custom_value, %{value: "world"})
                 ])
               ])
    end
  end

  describe "merge()" do
    test "merges the result correctly" do
      assert %{a: "hello", b: "world"} = Fixtures.fixtures([merge(:simple_map)])

      assert %{a: "hello", b: "world", c: %{a: "hello", b: "world"}} =
               Fixtures.fixtures([
                 merge(:simple_map),
                 put(:c, :custom_value, %{value: %{}}, [
                   merge(:simple_map)
                 ])
               ])
    end

    test "sets the parent correctly" do
      assert %{a_key: %{asserted_map: true}} =
               Fixtures.fixtures([
                 put(:a_key, :custom_value, %{value: %{hello: "world"}}, [
                   merge(:assert_parent_is_map)
                 ])
               ])
    end
  end

  describe "run()" do
    test "handles empty fixtures" do
      assert :some_value =
               Fixtures.fixtures([
                 run(fn fixtures, args ->
                   assert fixtures.parent == %{}
                   assert args == %{}
                   :some_value
                 end)
               ])
    end

    test "puts the result correctly" do
      assert %{hello: :world} = Fixtures.fixtures([run(:hello, fn _, _ -> :world end)])
    end

    test "handle multiple runs correctly" do
      assert %{hello: :bob} =
               Fixtures.fixtures([
                 run(:hello, fn _, _ -> :world end),
                 run(:hello, fn _, _ -> :bob end)
               ])
    end
  end

  describe "append()" do
    test "appends the result correctly" do
      assert [:simple_atom] = Fixtures.new([], %{}, [append(:simple_atom)]) |> Fixtures.fixtures()

      assert %{list: [:simple_atom]} =
               Fixtures.new(%{list: []}, %{}, [append([:list], :simple_atom)])
               |> Fixtures.fixtures()
    end
  end
end
