# SPDX-FileCopyrightText: Copyright 2024 Xiangzhuang Shen
# SPDX-License-Identifier: MIT

# SPDX-FileCopyrightText: Copyright 2023 Charlie Holtz
# SPDX-License-Identifier: Apache-2.0

defmodule Qwen.Generation do
  @moduledoc """
  通义千问大语言模型
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

  @doc """
  将通义千问大语言模型的对话结果解析为更加精简的格式，
  返回`{:ok, text_content}` 或 `{:error, message}`，而不是原始格式

  ## 精简格式(默认)
  ```elixir
  iex> import Qwen.Sigils
  iex> prompt = ~l"model: qwen-turbo
  ...>             system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话
  ...>             user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
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

  @doc """
  通义千问大语言模型(原始接口): 输入原始格式参数，输出原始格式结果


  ## 请求参数
  ```elixir
  params = [
    model: "qwen-turbo",
    input: %{
        messages: [
            %{
                role: "system",
                content: "你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话"
            },
            %{
                role: "user",
                content: "你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
            }
        ]
      },
    parameters: %{
      result_format: "message"
    }
  ]
  ```

  ## 发起请求
  ```elixir
  Qwen.generation(params, %Qwen.Config{})
  ```

  ## 请求响应

  ```elixir
  {:ok,
    %{
      output: %{
        "choices" => [
          %{
            "finish_reason" => "stop",
            "message" => %{
              "content" => "吾乃大唐诗仙李太白，异国文豪未识面，\n卡尔维诺名震欧罗巴，笔下世界幻如烟。\n《看不见的城市》藏深意，文字游戏人间篇，\n穿越时空织锦绣，如我醉酒舞剑篇。\n\n天马行空思绪远，寓言之中见哲理，\n与我青天揽明月，皆是诗心照万里。\n虽隔千山与万水，文学之心共通灵，\n愿尔作品长流传，犹如长江水东流。",
              "role" => "assistant"
            }
          }
        ]
      },
      usage: %{"input_tokens" => 63, "output_tokens" => 114, "total_tokens" => 177},
      request_id: "558791e3-dcbe-95d5-bbad-1b2fe3c2f6cf"
    }}
  ```
  """
  def generation(params, config \\ %Config{}) do
    fetch(params, config)
  end

  defp parse_chat(
         {:ok, %{output: %{"choices" => [%{"message" => %{"content" => text_content}} | _]}}}
       ),
       do: {:ok, text_content}

  defp parse_chat({:ok, %{output: %{"text" => text_content}}}),
    do: {:ok, text_content}

  # 解析异常返回，示例如下
  # {
  #   "code":"InvalidApiKey",
  #   "message":"Invalid API-key provided.",
  #   "request_id":"fb53c4ec-1c12-4fc4-a580-cdb7c3261fc1"
  # }
  defp parse_chat({:error, %{"message" => message}}), do: {:error, message}

  # 解析其他异常返回
  defp parse_chat({:error, any_error}), do: {:error, any_error}
end
