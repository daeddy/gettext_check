defmodule GettextCheckTest do
  use ExUnit.Case

  alias Expo.Message
  alias GettextCheck

  @moduletag :tmp_dir

  @file_path "priv/gettext/pt-br/LC_MESSAGES"

  describe "check/1" do
    setup %{tmp_dir: tmp_dir} do
      base_content = """
      ## "msgid"s in this file come from POT (.pot) files.
      ##
      ## Do not add, change, or remove "msgid"s manually here as
      ## they're tied to the ones in the corresponding POT file
      ## (with the same domain).
      ##
      ## Use "mix gettext.extract --merge" or "mix gettext.merge"
      ## to merge POT files into PO files.
      msgid ""
      msgstr ""
      "Language: ja"
      "Plural-Forms: nplurals=1; plural=0;"
      """

      missing_locale_content =
        base_content <>
          """
          #: path/component.ex:5
          #, elixir-autogen, elixir-format
          msgid "World"
          msgstr ""
          """

      missing_locale_content_plural =
        base_content <>
          """
          #: path/component.ex:5
          #, elixir-autogen, elixir-format
          msgid "should have %{count} item"
          msgid_plural "should have %{count} items"
          msgstr[0] ""
          msgstr[1] ""
          """

      locale_content_not_missing =
        base_content <>
          """
          #: path/component.ex:1
          #, elixir-autogen, elixir-format
          msgid "Hello"
          msgstr "Oi"
          """

      file_path_missing = "#{@file_path}/missing.po"
      file_path_missing_plural = "#{@file_path}/missing_plural.po"
      file_path_not_missing = "#{@file_path}/default.po"
      write_file(tmp_dir, file_path_missing, missing_locale_content)
      write_file(tmp_dir, file_path_missing_plural, missing_locale_content_plural)
      write_file(tmp_dir, file_path_not_missing, locale_content_not_missing)

      on_exit(fn -> File.rm(Path.join(tmp_dir, file_path_missing)) end)
      on_exit(fn -> File.rm(Path.join(tmp_dir, file_path_missing_plural)) end)
      on_exit(fn -> File.rm(Path.join(tmp_dir, file_path_not_missing)) end)

      %{
        tmp_dir: tmp_dir,
        file_path_missing: file_path_missing,
        file_path_missing_plural: file_path_missing_plural,
        file_path_not_missing: file_path_not_missing
      }
    end

    test "should check a file correctly", %{
      test: test,
      tmp_dir: tmp_dir,
      file_path_not_missing: file_path_not_missing
    } do
      assert [] =
               Mix.Project.in_project(test, tmp_dir, fn _module ->
                 GettextCheck.check(file_path_not_missing)
               end)
    end

    test "should return errors correctly", %{
      test: test,
      tmp_dir: tmp_dir,
      file_path_missing: file_path_missing
    } do
      assert [error] =
               Mix.Project.in_project(test, tmp_dir, fn _module ->
                 GettextCheck.check(file_path_missing)
               end)

      assert ["\n", "\e[0m", "msgid: 'World'", "\n", "\e[1m", "\e[31m", path, "\n"] = error
      assert path =~ "#{@file_path}/missing.po:16"
    end

    test "should return errors correctly [plural]", %{
      test: test,
      tmp_dir: tmp_dir,
      file_path_missing_plural: file_path_missing_plural
    } do
      assert [error_1, error_2] =
               Mix.Project.in_project(test, tmp_dir, fn _module ->
                 GettextCheck.check(file_path_missing_plural)
               end)

      assert [
               "\n",
               "\e[0m",
               "msgid: 'should have %{count} items'",
               "\n",
               "\e[1m",
               "\e[31m",
               path_1,
               "\n"
             ] = error_1

      assert path_1 =~ "#{@file_path}/missing_plural.po:18"

      assert [
               "\n",
               "\e[0m",
               "msgid: 'should have %{count} item'",
               "\n",
               "\e[1m",
               "\e[31m",
               path_2,
               "\n"
             ] = error_2

      assert path_2 =~ "#{@file_path}/missing_plural.po:17"
    end
  end

  describe "get_errors/2" do
    test "should return errors for missing translation in message [singular]" do
      assert [error] =
               GettextCheck.get_errors(%Message.Singular{msgid: "foo", msgstr: [""]}, @file_path)

      assert [
               "\n",
               "\e[0m",
               "msgid: 'foo'",
               "\n",
               "\e[1m",
               "\e[31m",
               path,
               "\n"
             ] = error

      assert path =~ "#{@file_path}:"
    end

    test "should return no errors from correct message [singular]" do
      assert [] =
               GettextCheck.get_errors(
                 %Message.Singular{msgid: "foo", msgstr: ["foo"]},
                 @file_path
               )
    end

    test "should return errors for missing translation in message [plural]" do
      assert [error_1, error_2] =
               GettextCheck.get_errors(
                 %Message.Plural{
                   msgid: ["bar"],
                   msgid_plural: ["bars"],
                   msgstr: %{0 => [""], 1 => [""]}
                 },
                 @file_path
               )

      assert ["\n", "\e[0m", "msgid: 'bars'", "\n", "\e[1m", "\e[31m", path_1, "\n"] = error_1
      assert path_1 =~ "#{@file_path}:"

      assert ["\n", "\e[0m", "msgid: 'bar'", "\n", "\e[1m", "\e[31m", path_2, "\n"] = error_2
      assert path_2 =~ "#{@file_path}:"
    end

    test "should return no errors from correct message [plural]" do
      assert [] =
               GettextCheck.get_errors(
                 %Message.Plural{
                   msgid: ["bar"],
                   msgid_plural: ["bars"],
                   msgstr: %{0 => ["bars"], 1 => ["barses"]}
                 },
                 @file_path
               )
    end
  end

  defp write_file(tmp_dir, path, contents) do
    path = Path.join(tmp_dir, path)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
  end
end
