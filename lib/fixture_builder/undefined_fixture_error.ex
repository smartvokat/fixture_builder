defmodule FixtureBuilder.UndefinedFixtureError do
  @moduledoc """
  Error raised when trying to run a fixture that is undefined.
  """
  alias __MODULE__

  defexception [:message]

  def exception({fixture_name, fixture_module}) do
    modules =
      fixture_module.__fixture_builder__(:fixtures)
      |> Enum.join(", ")
      |> String.replace("Elixir.", "")

    message =
      "Failed to execute fixture #{inspect(fixture_name)}. Please make sure it is defined in one of the " <>
        "following modules: #{modules}."

    %UndefinedFixtureError{message: message}
  end
end
