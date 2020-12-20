defmodule FixtureBuilder.Fixtures do
  @moduledoc ~S"""
  Defines a set of fixtures.

  The definition of a fixture is possible through one main API:
  `fixture/3`.
  """

  @doc """
  """
  @callback build(atom(), map(), FixtureBuilder.t()) :: FixtureBuilder.t() | any()

  @doc false
  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :factory_builder_fixtures, accumulate: true)

      @behaviour FixtureBuilder.Fixtures
      @on_definition {FixtureBuilder.Fixtures, :on_def}
      @before_compile {unquote(__MODULE__), :__before_compile__}
    end
  end

  @doc false
  def on_def(env, :def, :build, [name | _tail], _, _),
    do: Module.put_attribute(env.module, :factory_builder_fixtures, name)

  @doc false
  def on_def(_env, _kind, _name, _args, _guards, _body), do: nil

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def __fixture_builder__(:fixtures), do: @factory_builder_fixtures
    end
  end
end
