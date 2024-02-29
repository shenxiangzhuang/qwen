# SPDX-FileCopyrightText: Copyright 2024 Xiangzhuang Shen
# SPDX-License-Identifier: MIT

# SPDX-FileCopyrightText: Copyright 2023 Charlie Holtz
# SPDX-License-Identifier: Apache-2.0

defmodule Qwen.Generation do
  @moduledoc"""
  Qwen Generation
  """
  alias Qwen.Client
  alias Qwen.Config

  @base_url "/api/v1/services/aigc/text-generation/generation"

  def url(), do: @base_url

  def fetch(params, config \\ %Config{}) do
    # set paramters.result_format = "message" as default
    params =
      case length(params) do
        2 -> [parameters: %{result_format: "message"}] ++ params
        3 -> params
        _ -> raise ArgumentError, message: "The length of the params list is not in 2 or 3"
      end

    url()
    |> Client.api_post(params, config)
  end

  def generation(params, config \\ %Config{}) do
    fetch(params, config)
  end

  @doc """
  将通义千问大语言模型的对话结果解析为更加精简的格式，
  返回`{:ok, text_content}` 或 `{:error, message}`，而不是原始格式

  ## 精简格式(默认)
  ```elixir
  iex> import Qwen.Generation
  iex> prompt = ~l"model: qwen-turbo system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
  [
    model: "qwen-turbo",
    input: %{
      messages: [
        %{
          role: "system",
          content: "你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。"
        },
        %{
          role: "user",
          content: "你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
        }
      ]
    },
    parameters: %{}
  ]
  iex> Qwen.chat(prompt)
  {:ok,
  "我李白，醉卧青天云间游，笔下挥洒天地秋。虽非意大利文豪，但对异国才子亦有敬意。卡尔维诺如织梦者，编织文字的绮丽迷宫，\n《看不见的城市》唤起无尽想象，跨越时空的桥梁。\n心灵之旅如幻如真，寓言世界深邃如渊。\n他的故事如月挂天涯，照亮异域文化之光。\n才华横溢如星河璀璨，卡尔维诺在文学的夜空独步，\n虽未亲临其境，诗篇寄情以遥祝，\n愿他的奇思永照人间，让读者沉醉在永恒的篇章。"}
  ```

  ## 原始格式
  ```elixir
  {:ok,
  %{
    output: %{
      "finish_reason" => "stop",
      "text" => "我李白，醉卧青天云间游，笔下挥洒天地秋。虽非意大利文豪，但对异国才子亦有敬意。卡尔维诺如织梦者，编织文字的绮丽迷宫，\n《看不见的城市》唤起无尽想象，跨越时空的桥梁。\n心灵之旅如幻如真，寓言世界深邃如渊。\n他的故事如月挂天涯，照亮异域文化之光。\n才华横溢如星河璀璨，卡尔维诺在文学的夜空独步，\n虽未亲临其境，诗篇寄情以遥祝，\n愿他的奇思永照人间，让读者沉醉在永恒的篇章。"
    },
    usage: %{
      "input_tokens" => 33,
      "output_tokens" => 146,
      "total_tokens" => 179
    },
    request_id: "c02c1370-6d76-9628-b379-a59792f2b485"
  }}
  ```
  """
  def chat(text) do
    text
    |> generation()
    |> parse_chat()
  end

  defp parse_chat(
         {:ok, %{output: %{"choices" => [%{"message" => %{"content" => text_content}} | _]}}}
       ),
       do: {:ok, text_content}

  defp parse_chat({:ok, %{output: %{"text" => text_content}}}),
    do: {:ok, text_content}

  @doc """
  解析异常返回，示例如下
  {
    "code":"InvalidApiKey",
    "message":"Invalid API-key provided.",
    "request_id":"fb53c4ec-1c12-4fc4-a580-cdb7c3261fc1"
  }
  """
  defp parse_chat({:error, %{"message" => message}}), do: {:error, message}

  # 解析其他异常返回
  defp parse_chat({:error, any_error}), do: {:error, any_error}

  # sigil_l
  @doc """
  利用Elixir的Sigil，按照一定格式输入字符串，自动解析为请求需要的格式

  ## 示例一: 一般用法
  只需要指定`model`和`system`, `user`即可。

  ```elixir
  iex> import Qwen.Generation
  iex> ~l"model: qwen-turbo system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
  [
    model: "qwen-turbo",
    input: %{
      messages: [
        %{
          role: "system",
          content: "你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。"
        },
        %{
          role: "user",
          content: "你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
        }
      ]
    },
    parameters: %{}
  ]
  ```

  ## 示例二: 指定`parameters`
  通过`parameters.key: value`指定`parameters`部分的参数`key`为`value`,
  如加入`parameters.result_format: message`可以设置参数`parameters.result_format`为`message`

  ```elixir
  iex> import Qwen.Generation
  iex> ~l"model: qwen-turbo parameters.result_format: message system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
  [
    model: "qwen-turbo",
    input: %{
      messages: [
        %{
          role: "system",
          content: "你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。"
        },
        %{
          role: "user",
          content: "你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
        }
      ]
    },
    parameters: %{result_format: "message"}
  ]
  ```

  """
  def sigil_l(lines, _opts) do
    lines |> text_to_prompts()
  end

  defp text_to_prompts(text) when is_binary(text) do
    model = extract_model(text) |> String.trim()
    messages = extract_messages(text)
    parameters = extract_parameters(text)
    [model: model, input: %{messages: messages}, parameters: parameters]
  end

  defp extract_model(text) do
    extract_value_after_keyword(text, "model:")
  end

  defp extract_messages(text) do
    keywords = ["system:", "user:", "assistant:"]

    Enum.reduce_while(keywords, [], fn keyword, acc ->
      case extract_value_after_keyword(text, keyword) do
        nil ->
          {:cont, acc}

        value ->
          role = String.trim(keyword, ":")
          acc = acc ++ [%{role: role, content: String.trim(value)}]
          {:cont, acc}
      end
    end)
  end

  defp extract_parameters(text) do
    keywords = ["result_format:"]

    Enum.reduce_while(keywords, %{}, fn keyword, acc ->
      case extract_value_after_keyword(text, "parameters." <> keyword) do
        nil ->
          {:cont, acc}

        value ->
          param = String.trim(keyword, ":")
          acc = Map.put(acc, String.to_existing_atom(param), String.trim(value))
          {:cont, acc}
      end
    end)
  end

  defp extract_value_after_keyword(text, keyword) do
    pattern = ~r/#{keyword}\s*(.*?)(?=model:|system:|user:|assistant:|parameters|$)/s

    case Regex.run(pattern, text) do
      [_, value] -> value
      _ -> nil
    end
  end
end
