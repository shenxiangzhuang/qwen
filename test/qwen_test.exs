defmodule QwenTest do
  use ExUnit.Case
  import Qwen.Sigils

  # here we only specified some of the modules use doctest to AVOID the call of REST API
  doctest Qwen.Sigils

  test "greets the world" do
    assert :world == :world
  end
end
