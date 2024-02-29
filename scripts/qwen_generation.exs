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
