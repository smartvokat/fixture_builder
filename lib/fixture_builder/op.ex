defmodule FixtureBuilder.Op do
  @type path() :: list(String.t() | atom() | integer()) | String.t() | atom()

  @type ops() :: list(FixtureBuilder.Op.t())

  @type t() :: %__MODULE__{
          args: map(),
          children: FixtureBuilder.Op.ops(),
          fixture: atom(),
          name: atom(),
          path: FixtureBuilder.Op.path(),
          target_path: FixtureBuilder.Op.path(),
          extra: map()
        }

  defstruct name: nil,
            args: nil,
            children: [],
            path: [],
            fixture: nil,
            extra: %{},
            target_path: []
end
