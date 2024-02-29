# SPDX-FileCopyrightText: 2024 Xiangzhuang Shen
# SPDX-License-Identifier: MIT

# SPDX-FileCopyrightText: 2023 Marco Gallo
# SPDX-License-Identifier: MIT


defmodule Qwen.Client do
  @moduledoc false
  alias Qwen.Config
  use HTTPoison.Base

  def process_url(url), do: Config.api_url() <> url

  def process_response_body(body) do
    try do
      {status, res} = Jason.decode(body)

      case status do
        :ok ->
          {:ok, res}

        :error ->
          body
      end
    rescue
      _ ->
        body
    end
  end

  def handle_response(httpoison_response) do
    case httpoison_response do
      {:ok, %HTTPoison.Response{status_code: 200, body: {:ok, body}}} ->
        res =
          body
          |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
          |> Map.new()

        {:ok, res}

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{body: {:ok, body}}} ->
        {:error, body}

      {:ok, %HTTPoison.Response{body: {:error, body}}} ->
        {:error, body}

      # html error responses
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def request_headers(config) do
    [
      bearer(config),
      {"Content-type", "application/json"}
    ]
  end

  def bearer(config), do: {"Authorization", "Bearer #{config.api_key || Config.api_key()}"}

  def request_options(config), do: config.http_options || Config.http_options()


  def query_params(request_options, [_ | _] = params) do
    # The `request_options` may or may not be present, but the `params` are.
    # Therefore we can guarantee to return a non-empty keyword list, so we cam
    # modify the `request_options` unconditionnaly.
    request_options
    |> List.wrap()
    |> Keyword.merge([params: params], fn :params, old_params, new_params ->
      Keyword.merge(old_params, new_params)
    end)
  end

  def query_params(request_options, _params), do: request_options

  def api_post(url, params \\ [], config) do
    body =
      params
      |> Enum.into(%{})
      |> Jason.encode!()

    url
    |> post(body, request_headers(config), request_options(config))
    |> handle_response()
    end
end