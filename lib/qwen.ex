defmodule Qwen do
  @moduledoc """
  Documentation for `Qwen`.
  """
  alias Qwen.Config
  alias Qwen.Generation
  import Qwen.Sigils, only: :sigils

  @doc """
  通义千问大语言模型: 输入prompt，输出生成结果。
  注意在这之前需要先[开通DashScope并创建API-KEY](https://help.aliyun.com/zh/dashscope/developer-reference/activate-dashscope-and-create-an-api-key),
  之后通过`export DASHSCOPE_API_KEY="YOUR_DASHSCOPE_API_KEY"`设置好环境变量。

  ## 简单测试
  在设置好API KEY的环境变量后，可以通过预置的prompt测试是否可以正常使用通义千问的API

  ```elixir
  iex> import Qwen
  Qwen
  iex> Qwen.chat()
  {:ok,
  "你好，我是通义千问，由阿里云开发的AI助手。我被设计用来回答各种问题、提供信息和进行对话，无论你对科技、文化、历史、生活常识还是其他领域的问题，我都会尽力为你提供准确和详尽的回答。我不能感受情感，但我可以提供客观、中立的帮助。如果你有任何问题，请随时向我提问。"}
  ```

  ## 一般用法

  ```elixir
  iex> import Qwen.Sigils
  iex> prompt = ~l"model: qwen-turbo system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
  iex> Qwen.chat(prompt)
  {:ok,
  "我李白，醉卧青天云间游，笔下挥洒天地秋。虽非意大利文豪，但对异国才子亦有敬意。卡尔维诺如织梦者，编织文字的绮丽迷宫，\n《看不见的城市》唤起无尽想象，跨越时空的桥梁。\n心灵之旅如幻如真，寓言世界深邃如渊。\n他的故事如月挂天涯，照亮异域文化之光。\n才华横溢如星河璀璨，卡尔维诺在文学的夜空独步，\n虽未亲临其境，诗篇寄情以遥祝，\n愿他的奇思永照人间，让读者沉醉在永恒的篇章。"}
  ```

  """
  def chat(text \\ ~l"model: qwen-turbo user: 介绍下你自己") do
    Generation.chat(text)
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
    Generation.generation(params, config)
  end
end
