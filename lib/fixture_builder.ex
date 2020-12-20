defmodule FixtureBuilder do
  @moduledoc """
  Documentation for `FixtureBuilder`.
  """

  alias FixtureBuilder.Utils

  @type t() :: %__MODULE__{
          args: map(),
          data: map(),
          ops: list(FixtureBuilder.Op.t()),
          parent: any()
        }

  defstruct args: %{},
            data: %{},
            ops: [],
            parent: nil

  @doc false
  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :factory_builder_fixtures, accumulate: true)

      @before_compile {unquote(__MODULE__), :__before_compile__}

      require FixtureBuilder
      import FixtureBuilder, only: [import_fixtures: 1]

      def fixtures(ops) when is_list(ops),
        do: FixtureBuilder.fixtures(%FixtureBuilder{ops: ops}, __MODULE__)

      def fixtures(%FixtureBuilder.Op{} = op),
        do: FixtureBuilder.fixtures(%FixtureBuilder{ops: [op]}, __MODULE__)

      def fixtures(%FixtureBuilder{} = fixtures),
        do: FixtureBuilder.fixtures(fixtures, __MODULE__)

      def fixture(fixture, args \\ %{})

      def fixture(fixture, %FixtureBuilder{} = fixtures),
        do: FixtureBuilder.fixture(fixture, %{}, fixtures, __MODULE__)

      def fixture(fixture, args), do: FixtureBuilder.fixture(fixture, args, nil, __MODULE__)

      def fixture(fixture, args, %FixtureBuilder{} = fixtures),
        do: FixtureBuilder.fixture(fixture, args, fixtures, __MODULE__)

      def fixture(fixture, args, data),
        do: FixtureBuilder.fixture(fixture, args, %FixtureBuilder{data: data}, __MODULE__)

      @spec new() :: FixtureBuilder.t()
      def new(), do: FixtureBuilder.new(%{}, %{}, [])

      @spec new(list(FixtureBuilder.Op.t())) :: FixtureBuilder.t()
      def new(ops), do: FixtureBuilder.new(%{}, %{}, ops)

      @spec new(map(), list(FixtureBuilder.Op.t())) :: FixtureBuilder.t()
      def new(args, ops), do: FixtureBuilder.new(%{}, args, ops)

      @spec new(any(), map(), list(FixtureBuilder.Op.t())) :: FixtureBuilder.t()
      def new(initial_data, args, ops), do: FixtureBuilder.new(initial_data, args, ops)

      def put(path, fixture, args \\ %{})

      def put(path, fixture, args) when is_map(args),
        do: FixtureBuilder.Ops.put(path, fixture, args, [])

      def put(path, fixture, children) when is_list(children),
        do: FixtureBuilder.Ops.put(path, fixture, %{}, children)

      def put(path, fixture, args, children),
        do: FixtureBuilder.Ops.put(path, fixture, args, children)

      def append(fixture, args \\ %{})

      def append(path, fixture) when is_list(path),
        do: FixtureBuilder.Ops.append(path, fixture, %{}, [])

      def append(path, fixture, args) when is_list(path) and is_map(args),
        do: FixtureBuilder.Ops.append(path, fixture, args, [])

      def append(path, fixture, children)
          when is_list(path) and is_list(children),
          do: FixtureBuilder.Ops.append(path, fixture, %{}, children)

      def append(path, fixture, args, children),
        do: FixtureBuilder.Ops.append(path, fixture, args, children)

      def append(fixture, args) when is_map(args),
        do: FixtureBuilder.Ops.append([], fixture, args, [])

      def append(fixture, children) when is_list(children),
        do: FixtureBuilder.Ops.append([], fixture, %{}, children)

      def append(fixture, args, children),
        do: FixtureBuilder.Ops.append([], fixture, args, children)

      def merge(fixture, args \\ %{}),
        do: FixtureBuilder.Ops.merge(fixture, args)

      def run(callback),
        do: FixtureBuilder.Ops.run([], callback, [])

      def run(path, callback),
        do: FixtureBuilder.Ops.run(path, callback, [])

      def run(path, callback, children),
        do: FixtureBuilder.Ops.run([], callback, children)

      @doc """
      Merges keys from `source` into `target`.
      """
      @spec merge_args(map(), map()) :: map()
      def merge_args(target, source), do: Map.merge(source, target)

      @doc """
      Merges keys from `source` into `target` according to the defined `mapping`.
      """
      @spec merge_args(map(), FixtureBuilder.t() | map(), %{atom() => atom() | list()}) :: map()
      def merge_args(target, %FixtureBuilder{data: source}, mapping),
        do: merge_args(target, source, mapping)

      def merge_args(target, source, mapping) do
        Enum.reduce(mapping, target, fn {attr, path}, acc ->
          if !Map.has_key?(target, attr) do
            Map.put_new(acc, attr, FixtureBuilder.Utils.get(source, path))
          else
            acc
          end
        end)
      end
    end
  end

  @doc """
  Imports a fixture module.
  """
  defmacro import_fixtures(module) do
    quote do
      Module.put_attribute(__MODULE__, :factory_builder_fixtures, unquote(module))
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def __fixture_builder__(:fixtures), do: @factory_builder_fixtures
    end
  end

  @doc """
  Adds an operation to a `FixtureBuilder` struct.
  """
  @spec add(FixtureBuilder.t(), FixtureBuilder.Op.t()) :: FixtureBuilder.t()
  def add(%FixtureBuilder{} = fixtures, op), do: %{fixtures | ops: fixtures.ops ++ [op]}

  @doc """
  Executes a `FixtureBuilder` struct.
  """
  @spec fixtures(FixtureBuilder.t(), any) :: any
  def fixtures(fixtures, module),
    do: Map.get(FixtureBuilder.Executer.execute(fixtures, module), :data)

  @doc """
  Executes a single fixture.
  """
  @spec fixture(atom(), map(), FixtureBuilder.t(), any()) :: any()
  def fixture(fixture, args, fixtures, module) do
    fixture_module = Utils.find_fixture_module!(fixture, module)
    fixtures = if is_nil(fixtures), do: %FixtureBuilder{}, else: fixtures
    apply(fixture_module, :build, [fixture, args, fixtures])
  end

  @doc """
  Creates a new `FixtureBuilder` struct.
  """
  @spec new(any(), map(), list(FixtureBuilder.Op.t())) :: FixtureBuilder.t()
  def new(initial_data, args, ops), do: %FixtureBuilder{data: initial_data, args: args, ops: ops}
end
