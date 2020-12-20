defmodule FixtureBuilder.Test.Fixtures do
  use FixtureBuilder

  import_fixtures(FixtureBuilder.Test.Fixtures.SimpleBuilder)
  import_fixtures(FixtureBuilder.Test.Fixtures.ComplexBuilder)
end
