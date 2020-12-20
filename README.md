# FixtureBuilder

FixtureBuilder is a library to define and build complex fixtures for your tests.

```elixir
env = FixtureBuilder.fixtures([
  put(:group, :group, %{name: Faker.Team.name()}, [
    put(:user, :user)
  ])
])

assert %Group{} = env.group
assert %User{} = env.group.user
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fixture_builder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fixture_builder, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fixture_builder](https://hexdocs.pm/fixture_builder).

