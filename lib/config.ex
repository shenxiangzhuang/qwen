# SPDX-FileCopyrightText: 2024 Xiangzhuang Shen
# SPDX-License-Identifier: MIT

# SPDX-FileCopyrightText: 2023 Marco Gallo
# SPDX-License-Identifier: MIT

defmodule Qwen.Config do
  @moduledoc """
  Reads configuration on application start, parses all environment variables (if any)
  and caches the final config in memory to avoid parsing on each read afterwards.
  """

  defstruct api_key: nil,
            api_url: nil,
            http_options: nil

  @qwen_url "https://dashscope.aliyuncs.com"

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  # API Key
  def api_key, do: get_config_value(:api_key, System.get_env("DASHSCOPE_API_KEY"))

  # API Url
  def api_url, do: get_config_value(:api_url, @qwen_url)

  # HTTP Options
  def http_options, do: get_config_value(:http_options, [])

  defp get_config_value(key, default) do
    value =
      :qwen
      |> Application.get_env(key)
      |> parse_config_value()

    if is_nil(value), do: default, else: value
  end

  defp parse_config_value({:system, env_name}), do: System.fetch_env!(env_name)

  defp parse_config_value({:system, :integer, env_name}) do
    env_name
    |> System.fetch_env!()
    |> String.to_integer()
  end

  defp parse_config_value(value), do: value
end
