defmodule Qwen.Image do
  @moduledoc """
  通义万相: 文生图模型
  """
  alias Qwen.Client
  alias Qwen.Config

  @post_url "/api/v1/services/aigc/text2image/image-synthesis"
  @get_url "/api/v1/tasks"

  def post_url(), do: @post_url
  def get_url(), do: @get_url

  @doc """
  根据`text`生成图片，存储到`image_path`并返回
  """
  def text_to_image(text, image_path) do
    text |> image_generation(image_path)
  end

  @doc """
  根据`text`生成图片，返回`image_url`
  """
  def text_to_image(text) do
    text |> image_generation
  end

  def image_generation_save(params, image_path, config \\ %Config{}) do
    # params -> task_id -> image_url -> image file path
    image_generation(params, config)
    |> save_image(image_path)
  end

  def image_generation(params, config \\ %Config{}) do
    # params -> task_id -> image_url
    post_async_generation_task(params, config)
    |> parse_task_id()
    |> get_task_status()
  end

  def post_async_generation_task(params, config \\ %Config{}) do
    # 固定使用 enable，表明使用异步方式提交作业(文档要求必须使用异步方式)
    dynamic_headers = [
      {"X-DashScope-Async", "enable"}
    ]

    post_url()
    |> Client.api_post(params, config, dynamic_headers)
  end

  def get_task_status(params \\ [], config \\ %Config{}, task_id_string) do
    (get_url() <> "/" <> task_id_string)
    |> Client.api_get(params, config)
    |> parse_image_url()
  end

  def parse_task_id({:ok, %{output: %{"task_id" => task_id}}}) do
    task_id
  end

  def parse_task_id({:error, _} = raw_resp) do
    raw_resp
  end

  defp parse_image_url(
         {:ok, %{output: %{"task_status" => task_status, "task_id" => task_id}}} = resp
       ) do
    case task_status do
      "PENDING" ->
        IO.puts("Pending...")
        :timer.sleep(5000)
        get_task_status(task_id)

      "RUNNING" ->
        IO.puts("Running...")
        :timer.sleep(3000)
        get_task_status(task_id)

      "SUCCEEDED" ->
        {:ok, %{output: %{"results" => [%{"url" => image_url} | _]}}} = resp
        {:ok, image_url}

      _ ->
        {:error, resp}
    end
  end

  defp parse_image_url({:error, _} = raw_resp) do
    raw_resp
  end

  def save_image({:ok, image_url}, image_path) do
    Client.image_download(image_url, image_path)
  end
end
