defmodule FixtureBuilder.Executer do
  @moduledoc false

  alias FixtureBuilder.Op
  alias FixtureBuilder.Utils

  def execute(fixtures, module), do: execute_next(fixtures, module)

  defp execute_next(%FixtureBuilder{ops: []} = fixtures, _), do: fixtures

  defp execute_next(%FixtureBuilder{ops: [%Op{name: :put} = op | tail]} = fixtures, module) do
    fixtures = Map.put(fixtures, :parent, Utils.get(fixtures.data, Enum.slice(op.path, 0..-2)))

    case apply_fixture(op, fixtures, module) do
      %FixtureBuilder{} = nested_fixtures ->
        nested_fixtures

      result ->
        data = Utils.update(fixtures.data, op.path, fn _ -> result end)
        nested_ops = Enum.map(op.children, &Map.put(&1, :path, op.path ++ &1.path))
        %{fixtures | data: data, ops: nested_ops ++ tail}
    end
    |> execute_next(module)
  end

  defp execute_next(%FixtureBuilder{ops: [%Op{name: :append} = op | tail]} = fixtures, module) do
    fixtures = Map.put(fixtures, :parent, Utils.get(fixtures.data, op.path))

    case apply_fixture(op, fixtures, module) do
      %FixtureBuilder{} = nested_fixtures ->
        nested_fixtures

      result ->
        data =
          Utils.update(fixtures.data, op.path, fn
            value when is_list(value) ->
              value ++ [result]

            value ->
              raise RuntimeError,
                    "Expected a list to append to, got: #{inspect(value)}. " <>
                      "Make sure the parent is a list and/or you provided the correct " <>
                      "initial data when using fixture composition."
          end)

        nested_ops = Enum.map(op.children, &Map.put(&1, :path, op.path ++ &1.path))
        %{fixtures | data: data, ops: nested_ops ++ tail}
    end
    |> execute_next(module)
  end

  defp execute_next(%FixtureBuilder{ops: [%Op{name: :merge} = op | tail]} = fixtures, module) do
    fixtures = Map.put(fixtures, :parent, Utils.get(fixtures.data, op.path))

    case apply_fixture(op, fixtures, module) do
      %FixtureBuilder{} = nested_fixtures ->
        nested_fixtures

      result ->
        data =
          Utils.update(fixtures.data, op.path, fn
            value when is_map(value) ->
              Map.merge(value, result)

            value ->
              raise RuntimeError,
                    "Expected a map to merge, got: #{inspect(value)}. " <>
                      "Make sure the parent is a map and/or you provided the correct " <>
                      "initial data when using fixture composition."
          end)

        nested_ops = Enum.map(op.children, &Map.put(&1, :path, op.path ++ &1.path))
        %{fixtures | data: data, ops: nested_ops ++ tail}
    end
    |> execute_next(module)
  end

  defp execute_next(%FixtureBuilder{ops: [%Op{name: :run} = op | tail]} = fixtures, module) do
    fixtures = Map.put(fixtures, :parent, Utils.get(fixtures.data, Enum.slice(op.path, 0..-2)))
    result = apply(op.extra.callback, [fixtures, fixtures.args])
    data = Utils.update(fixtures.data, op.path, fn _ -> result end)
    nested_ops = Enum.map(op.children, &Map.put(&1, :path, op.path ++ &1.path))

    %{fixtures | data: data, ops: nested_ops ++ tail}
    |> execute_next(module)
  end

  defp apply_fixture(op, fixtures, module) do
    fixture_module = Utils.find_fixture_module!(op.fixture, module)

    args =
      if is_function(op.args, 1) do
        op.args.(fixtures.data)
      else
        op.args
      end

    case apply(fixture_module, :build, [op.fixture, args, fixtures]) do
      %FixtureBuilder{} = nested_fixtures ->
        nested_data = Utils.update(fixtures.data, op.path, fn _ -> nested_fixtures.data end)
        nested_ops = Enum.map(nested_fixtures.ops, &Map.put(&1, :path, op.path ++ &1.path))
        tail = Enum.map(op.children, &Map.put(&1, :path, op.path ++ &1.path))

        nested_fixtures
        |> Map.put(:data, nested_data)
        |> Map.put(:ops, nested_ops)
        |> execute_next(module)
        |> Map.put(:ops, tail ++ List.delete_at(fixtures.ops, 0))

      value ->
        value
    end
  end
end
