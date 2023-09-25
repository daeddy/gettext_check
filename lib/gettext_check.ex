defmodule GettextCheck do
  @moduledoc """
  `GettextCheck` module allows to check for missing translations
  in [gettext](https://www.gnu.org/software/gettext/) `po` and `pot` files.

  It is made to work with the [elixir-gettext/gettext](https://github.com/elixir-gettext/gettext/blob/main/lib/gettext.ex)
  library.

  ## Basic Overview

  Using [elixir-gettext/gettext](https://github.com/elixir-gettext/gettext/blob/main/lib/gettext.ex)
  on you elixir project will create a `priv/gettext`
  directory with the following structure:

      priv/gettext
      ├── en
      │   └── LC_MESSAGES
      │       └── default.po
      └── en_US
          └── LC_MESSAGES
              └── default.po

  These files might be missing translations under `msgstr`
  (or `msgstr[0]` and `msgstr[1]` for plural translations).
  In a typical dev flow you would add the translations manually
  after extracting them from your code.

  Runing `GettextCheck` before pushing your code to a CI/CD
  pipeline can help prevent pushing mising translations to
  production.

  > This library uses [expo](https://hexdocs.pm/expo/readme.html)
  internally to parse the `po`/`pot` files.

  ## Usage

  Call `mix gettext_check` from the root of your project.

  Any missing translations will be listed in the output with the respective line number

  ```bash
        Missing translations:

        msgid: 'Online'
        /app/priv/locales/ja/LC_MESSAGES/default.po:7364
  ```

  ## Configuration

  You need to specify the locale but the priv directory is optional
  (default to `priv/gettext`).

  `GettextCheck` can be configured in two ways:

  #### 1. Command line options

  ```bash
    mix gettext_check --locale ja --priv priv/gettext
  ```

  #### 2. Mix config

  ```elixir
    config :gettext_check,
      locale: "ja",
      priv: "priv/gettext"
  ```

  """

  @root_path Path.dirname(__DIR__)

  alias Expo.Messages
  alias Expo.Message

  @doc """
  Checks a file for missing translation and returns a list of formatted errors.

  ## Examples

      iex> check("priv/locales/ja/LC_MESSAGES/default.po")
      [
        [_, _ANSI_reset, "msgid: Hello'", _, _ANSI_bright, _ANSI_red, "/app/priv/locales/ja/LC_MESSAGES/default.po:12", _],
        [_, _ANSI_reset, "msgid: World'", _, _ANSI_bright, _ANSI_red, "/app/priv/locales/ja/LC_MESSAGES/default.po:15", _]
      ]

  """
  @spec check(String.t()) :: [String.t()]
  def check(file_path) do
    result = Expo.PO.parse_file!(file_path)
    %Messages{messages: messages} = result

    Enum.reduce(messages, [], fn msg, errors ->
      get_errors(msg, file_path) ++ errors
    end)
  end

  @doc """
  Gets any missing translation errors from a message.

  ## Examples

      iex> get_errors(%Message.Singular{msgid: ["foo"], msgstr: [""]}, "priv/locales/ja/LC_MESSAGES/default.po")
      [
        [_, _ANSI_reset, "msgid: foo'", _, _ANSI_bright, _ANSI_red, "/app/priv/locales/ja/LC_MESSAGES/default.po:", _]
      ]

      iex> get_errors(%Message.Singular{msgid: ["bar"], msgstr: ["bar"]}, "priv/locales/ja/LC_MESSAGES/default.po")
      []

      iex> get_errors(%Message.Plural{msgid: ["bar"], msgid_plural: ["bars"], msgstr: %{0 => [""], 1 => [""]}}, "priv/locales/ja/LC_MESSAGES/default.po")
      [
        [_, _ANSI_reset, "msgid: bars'", _, _ANSI_bright, _ANSI_red, "/app/priv/locales/ja/LC_MESSAGES/default.po:", _],
        [_, _ANSI_reset, "msgid: bar'", _, _ANSI_bright, _ANSI_red, "/app/priv/locales/ja/LC_MESSAGES/default.po:", _]
      ]

  """
  @spec get_errors(Message.t(), String.t()) :: [String.t()] | nil
  def get_errors(%Message.Singular{} = message, file_path) do
    %Message.Singular{msgid: msgid, msgstr: msgstr} = Message.Singular.rebalance(message)

    if missing_msg?(msgstr) do
      line = Message.Singular.source_line_number(message, :msgstr)

      [format_error(msgid, file_path, line)]
    else
      []
    end
  end

  def get_errors(%Message.Plural{} = message, file_path) do
    %Message.Plural{msgid: msgid, msgid_plural: msgid_plural, msgstr: msgstr} =
      Message.Plural.rebalance(message)

    Enum.reduce(msgstr, [], fn {index, msg}, errors ->
      id = if index > 0, do: msgid_plural, else: msgid

      if missing_msg?(msg) do
        line = Message.Plural.source_line_number(message, {:msgstr, index})

        [format_error(id, file_path, line) | errors]
      else
        errors
      end
    end)
  end

  @spec missing_msg?([String.t()]) :: boolean
  defp missing_msg?(msgstr) do
    Enum.any?(msgstr, &(&1 == ""))
  end

  defp format_error(msgid, file_path, line) do
    [
      "\n",
      IO.ANSI.reset(),
      "msgid: '#{msgid}'",
      "\n",
      IO.ANSI.bright(),
      IO.ANSI.red(),
      "#{@root_path}/#{file_path}:#{line}",
      "\n"
    ]
  end
end
