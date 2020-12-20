defmodule FixtureBuilder.Ops do
  @moduledoc false

  @spec put(FixtureBuilder.Op.path(), atom(), map(), FixtureBuilder.Op.ops()) ::
          FixtureBuilder.Op.t()
  def put(path, fixture, args, children),
    do: %FixtureBuilder.Op{
      args: args,
      children: children,
      fixture: fixture,
      name: :put,
      path: List.wrap(path)
    }

  @spec append(FixtureBuilder.Op.path(), atom(), map(), list(FixtureBuilder.Op.t())) ::
          FixtureBuilder.Op.t()
  def append(path, fixture, args, children),
    do: %FixtureBuilder.Op{
      args: args,
      children: children,
      fixture: fixture,
      name: :append,
      path: List.wrap(path)
    }

  @spec merge(atom(), map()) :: FixtureBuilder.Op.t()
  def merge(fixture, args),
    do: %FixtureBuilder.Op{
      args: args,
      fixture: fixture,
      name: :merge
    }

  @spec run(FixtureBuilder.Op.path(), any(), FixtureBuilder.Op.ops()) :: FixtureBuilder.Op.t()
  def run(path, callback, children),
    do: %FixtureBuilder.Op{
      children: children,
      extra: %{callback: callback},
      name: :run,
      path: List.wrap(path)
    }
end
