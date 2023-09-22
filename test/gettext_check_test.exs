defmodule GettextCheckTest do
  use ExUnit.Case
  doctest GettextCheck

  test "greets the world" do
    assert GettextCheck.hello() == :world
  end
end
