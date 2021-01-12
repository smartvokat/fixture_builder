defmodule FixtureBuilder.Utils do
  @moduledoc false

  alias FixtureBuilder.Op

  @spec find_fixture_module!(atom(), any()) :: any()
  def find_fixture_module!(fixture_name, fixture_module) do
    result =
      fixture_module.__fixture_builder__(:fixtures)
      |> Enum.find(fn mod ->
        fixture_names = mod.__fixture_builder__(:fixtures)
        Enum.member?(fixture_names, fixture_name)
      end)

    if is_nil(result) do
      raise FixtureBuilder.UndefinedFixtureError, {fixture_name, fixture_module}
    end

    result
  end

  def update(data, [], updater), do: updater.(data)
  def update(data, path, updater), do: Kernel.update_in(data, get_path(path), updater)

  def has?(data, _) when not is_map(data) and not is_list(data), do: false

  def has?(data, [idx]) when is_list(data) and is_integer(idx),
    do: Enum.at(data, idx, :__empty__) !== :__empty__

  def has?(data, [idx | tail]) when is_list(data) and is_integer(idx),
    do: Enum.at(data, idx, :__empty__) !== :__empty__ && has?(Enum.at(data, idx), tail)

  def has?(data, [key]) when is_map(data),
    do: Map.has_key?(data, key)

  def has?(data, [key | tail]) when is_map(data),
    do: Map.has_key?(data, key) && has?(data[key], tail)

  def has?(_, []), do: false

  def get(data, path, default \\ nil)
  def get(data, _, default) when not is_map(data) or is_struct(data), do: default
  def get(data, [], _), do: data

  def get(data, path, default) do
    if has?(data, path) do
      Kernel.get_in(data, get_path(path))
    else
      default
    end
  end

  def get_path(path) do
    path
    |> List.wrap()
    |> Enum.map(fn
      item when is_integer(item) -> Access.at(item)
      item when is_binary(item) or is_atom(item) -> Access.key(item)
    end)
  end

  def get_parent_path(%Op{path: path, target_path: target_path}),
    do: Enum.slice(path, 0..(length(target_path) * -1 - 1))
end
