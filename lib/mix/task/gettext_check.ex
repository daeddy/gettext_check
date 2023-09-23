defmodule Mix.Tasks.GettextCheck do
  @shortdoc "Checks gettext translations for missing translations"

  @moduledoc """
  Checks gettext translations for missing translations and raises
  an error if a translation is missing.

  Your files must be saved in the [gettext](https://github.com/elixir-gettext/gettext#usage) directory structure
  e.g. `priv/gettext/LOCALE/LC_MESSAGES/DOMAIN.po`

  GNU gettext `.pot`, `po` files are supported.

  ```bash
  mix gettext_check [OPTIONS]
  ```

  ## Options

  * `--locale` or `-l` - the locale to check
    * Will be used with priv to find the locale files (e.g. `{priv}/{locale}/LC_MESSAGES`)
    * This can also be set under the config
    * Required either here or under the config
  * `--priv` or `-p` - the path to the priv directory
    * Defaults to `priv/gettext`
    * This can also be set under the config
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
    files = Path.wildcard("#{path}/*.{po,pot}")

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
