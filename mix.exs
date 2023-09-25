defmodule GettextCheck.MixProject do
  use Mix.Project

  @description "Check gettext translations for missing translations"

  @version "0.2.0"
  @repo_url "https://github.com/daeddy/gettext_check"

  def project do
    [
      app: :gettext_check,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],

      # Hex
      description: @description,
      package: package(),

      # Docs
      name: "gettext_check",
      docs: [
        source_ref: "v#{@version}",
        main: "GettextCheck",
        source_url: @repo_url
      ]
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs *.md),
      maintainers: ["Eduardo Porto"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url}
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
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end
end
