defmodule Mix.Tasks.GettextCheck.Test do
  use ExUnit.Case, async: true

  alias Mix.Tasks.GettextCheck

  @moduletag :tmp_dir

  setup %{test: test, tmp_dir: tmp_dir} do
    locale_content = """
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

    #: path/component.ex:1
    #, elixir-autogen, elixir-format
    msgid "Hello"
    msgstr "Oi"

    #: path/component.ex:5
    #, elixir-autogen, elixir-format
    msgid "World"
    msgstr ""
    """

    file_path_po = "priv/gettext/pt-br/LC_MESSAGES/default.po"
    file_path_pot = "priv/gettext/pt-br/LC_MESSAGES/default.po"
    write_file(tmp_dir, file_path_po, locale_content)
    write_file(tmp_dir, file_path_pot, locale_content)

    on_exit(fn -> File.rm(Path.join(tmp_dir, file_path_po)) end)
    on_exit(fn -> File.rm(Path.join(tmp_dir, file_path_pot)) end)

    %{test: test, tmp_dir: tmp_dir, file_path_po: file_path_po, file_path_pot: file_path_pot}
  end
  describe "run/1" do
    test "lists missing translations for po files", %{test: test, tmp_dir: tmp_dir, file_path_po: file_path_po} do
      %Mix.Error{message: message} =
        assert_raise Mix.Error, fn ->
          Mix.Project.in_project(test, tmp_dir, fn _module -> GettextCheck.run(["-l", "pt-br"]) end)
        end

      assert message =~ "Missing translations"
      assert message =~ "text: 'World"
      assert message =~ "#{file_path_po}:22"
    end

    test "lists missing translations for pot files", %{test: test, tmp_dir: tmp_dir, file_path_pot: file_path_pot} do
      %Mix.Error{message: message} =
        assert_raise Mix.Error, fn ->
          Mix.Project.in_project(test, tmp_dir, fn _module -> GettextCheck.run(["-l", "pt-br"]) end)
        end

      assert message =~ "Missing translations"
      assert message =~ "text: 'World"
      assert message =~ "#{file_path_pot}:22"
    end

    test "returns error for invalid args", %{test: test, tmp_dir: tmp_dir} do
      %Mix.Error{message: message} =
        assert_raise Mix.Error, fn ->
          Mix.Project.in_project(test, tmp_dir, fn _module -> GettextCheck.run(["-err", "pt-br"]) end)
        end

      assert message =~ "No locale specified. Please use --locale or -l"

      %Mix.Error{message: message} =
        assert_raise Mix.Error, fn ->
          Mix.Project.in_project(test, tmp_dir, fn _module ->
            GettextCheck.run(["-l", "pt-br", "-p", "missing/dir"])
          end)
        end

      assert message =~ "No locale files found in missing/dir/pt-br/LC_MESSAGES for locale: 'pt-br'"
    end

    test "returns error for missing file", %{test: test, tmp_dir: tmp_dir} do
      %Mix.Error{message: message} =
        assert_raise Mix.Error, fn ->
          Mix.Project.in_project(test, tmp_dir, fn _module -> GettextCheck.run(["-l", "ja"]) end)
        end

      assert message =~ "No locale files found in priv/gettext/ja/LC_MESSAGES for locale: 'ja'"
    end
  end

  defp write_file(tmp_dir, path, contents) do
    path = Path.join(tmp_dir, path)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
  end
end
