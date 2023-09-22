defmodule GettextCheck do
  @moduledoc """
  Documentation for `GettextCheck`.
  """

  @root_path Path.dirname(__DIR__)

  alias Expo.Messages
  alias Expo.Message

  @doc """
  Checks a file for missing translation and returns a list of formatted errors.

  ## Examples

      iex> check("priv/locales/ja/LC_MESSAGES/default.po")
      [
        "
          text: 'Online'
          /root/gettext_check/priv/locales/ja/LC_MESSAGES/default.po:7364
        ",
        "
          text: 'already assigned'
          /root/gettext_check/priv/locales/ja/LC_MESSAGES/errors.po:108
        "
      ]

  """
  @spec check(String.t()) :: [String.t()]
  def check(file_path) do
    result = Expo.PO.parse_file!(file_path)
    %Messages{messages: messages} = result

    Enum.reduce(messages, [], fn msg, errors ->
      error = get_errors(msg, file_path)

      if error != nil do
        [error | errors]
      else
        errors
      end
    end)
  end

  @doc """
  Checks a message for missing translation and returns any errors.

  ## Examples

      iex> get_errors(%Message.Singular{msgid: ["foo"], msgstr: [""]}, "priv/locales/ja/LC_MESSAGES/default.po")
      [
        "
          text: 'foo'
          /root/gettext_check/priv/locales/ja/LC_MESSAGES/default.po:2
        "
      ]

      iex> get_errors(%Message.Singular{msgid: ["bar"], msgstr: ["bar"]}, "priv/locales/ja/LC_MESSAGES/default.po")
      []

      iex> get_errors(%Message.Plural{msgid: ["bar"], msgstr: %{0 => [""], 1 => [""]}}, "priv/locales/ja/LC_MESSAGES/default.po")
      [
        "
          text: 'bar'
          /root/gettext_check/priv/locales/ja/LC_MESSAGES/default.po:2
        ",
        "
          text: 'bar'
          /root/gettext_check/priv/locales/ja/LC_MESSAGES/default.po:3
        "
      ]

  """
  @spec get_errors(Message.t(), String.t()) :: [String.t()] | nil
  def get_errors(%Message.Singular{} = message, file_path) do
    %Message.Singular{msgstr: msgstr} = Message.Singular.rebalance(message)

    if missing_msg?(msgstr) do
      [format_error(message, file_path)]
    else
      nil
    end
  end

  def get_errors(%Message.Plural{} = message, file_path) do
    %Message.Plural{msgstr: msgstr} = Message.Plural.rebalance(message)

    errors =
      Enum.reduce(msgstr, [], fn {index, msg}, errors ->
        if missing_msg?(msg) do
          [format_error(message, index, file_path) | errors]
        else
          errors
        end
      end)

    if errors != [] do
      errors
    else
      nil
    end
  end

  @spec missing_msg?([String.t()]) :: boolean
  defp missing_msg?(msgstr) do
    Enum.any?(msgstr, &(&1 == ""))
  end

  @spec format_error(Message.t(), String.t()) :: String.t()
  defp format_error(%Message.Singular{msgid: msgid} = message, file_path) do
    line = Message.Singular.source_line_number(message, :msgstr)

    """

    text: '#{msgid}'
    #{@root_path}/#{file_path}:#{line}

    """
  end

  defp format_error(
         %Message.Plural{msgid: msgid, msgid_plural: msgid_plural} = message,
         index,
         file_path
       ) do
    id = if index > 0, do: msgid_plural, else: msgid
    line = Message.Plural.source_line_number(message, {:msgstr, index})

    """

    text: '#{id}'
    #{@root_path}/#{file_path}:#{line}

    """
  end
end
