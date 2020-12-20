defmodule FixtureBuilder.MixProject do
  use Mix.Project

  def project do
    [
      app: :fixture_builder,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "FixtureBuilder",
      source_url: "https://github.com/smartvokat/fixture_builder",
      homepage_url: "https://github.com/smartvokat/fixture_builder"
      # docs: [
      #   main: "MyApp", # The main page in the docs
      #   logo: "path/to/logo.png",
      #   extras: ["README.md"]
      # ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
