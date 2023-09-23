defmodule GettextCheck.MixProject do
  use Mix.Project

  @description "Check gettext translations for missing keys"

  def project do
    [
      app: :gettext_check,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      description: @description,
      package: package(),
      deps: deps()
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Eduardo Porto"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/daeddy/gettext_check"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:expo, "~> 0.4.0"},

      # Dev deps
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev},
      {:excoveralls, "~> 0.17", only: :test},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end
end
