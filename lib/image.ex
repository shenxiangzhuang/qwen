defmodule Qwen.Image do
  @moduledoc """
  Qwen Generation
  """
  alias Erl2exVendored.Cli
  alias Qwen.Client
  alias Qwen.Config

  @post_url "/api/v1/services/aigc/text2image/image-synthesis"
  @get_url "/api/v1/tasks"

  def post_url(), do: @post_url
  def get_url(), do: @get_url

  def post_async_generation_task(params, config \\ %Config{}) do
    # 固定使用 enable，表明使用异步方式提交作业(文档要求必须使用异步方式)
    dynamic_headers = [
      {"X-DashScope-Async", "enable"}
    ]

    post_url()
    |> Client.api_post(params, config, dynamic_headers)
  end

  def get_task_status(params, config \\ %Config{}, task_id_string) do
    get_url() <> "/" <> task_id_string
    |> Client.api_get(params, config)
  end

  def image_generation(params, config \\ %Config{}) do
    post_async_generation_task(params, config)
    # TODO: parse task_id and query status until success or fail
  end

end
