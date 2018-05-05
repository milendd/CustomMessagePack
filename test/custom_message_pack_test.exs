defmodule CustomMessagePackTest do
  use ExUnit.Case
  doctest CustomMessagePack

  test "greets the world" do
    assert CustomMessagePack.hello() == :world
  end
end
