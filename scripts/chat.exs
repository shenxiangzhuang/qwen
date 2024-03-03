import Qwen.Sigils


# sigil_l调用
default_resp_prompt = ~l"model: qwen-turbo system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
message_resp_prompt = ~l"model: qwen-turbo parameters.result_format: message system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
text_resp_prompt = ~l"model: qwen-turbo parameters.result_format: text system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"

default_resp_prompt |> Qwen.chat
message_resp_prompt |> Qwen.chat
text_resp_prompt |> Qwen.chat


# 原始请求调用
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

Qwen.generation(params, %Qwen.Config{})
