defmodule Mix.Tasks.GettextCheck.Check do
  @shortdoc "Creates Minio buckets"

  @moduledoc """
  Creates the Minio buckets and policies needed in the dev and test environment.
  """

  use Mix.Task

  @default_priv "priv/gettext"

  @impl Mix.Task
  def run(args) do
    {opts, _} =
      OptionParser.parse!(args,
        switches: [locale: :string, priv: :string],
        aliases: [l: :locale, p: :priv]
      )

    mix_config = Mix.Project.config()
    config = mix_config[:gettext_check] || []
    locale = config[:locale] || opts[:locale]

    if locale == nil do
      Mix.raise("No locale specified. Please use --locale or -l")
    end

    priv = config[:priv] || opts[:priv] || @default_priv

    path = Path.join([priv, locale, "LC_MESSAGES"])
    files = Path.wildcard("#{path}/*.po")

    if files == [] do
      Mix.raise("No locale files found in #{path} for locale: '#{locale}'")
    end

    errors = Enum.map(files, &GettextCheck.check/1)

    if errors != [] do
      message = """
        Missing translations:

        #{errors}
      """

      Mix.raise(message)
    end
  end
end
