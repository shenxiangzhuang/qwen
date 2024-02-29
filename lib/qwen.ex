defmodule Qwen do
  @moduledoc """
  Documentation for `Qwen`.
  """
  alias Qwen.Config
  alias Qwen.Generation

  @doc """
  text generation parsed chat api
  """
  def chat(text) do
    Generation.chat(text)
  end

  @doc """
  text generation naive api
  """
  def generation(params, config \\ %Config{}) do
    Generation.generation(params, config)
  end
end
