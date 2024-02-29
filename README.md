# Qwen(千问)

对通义千问REST API
([API详情](https://help.aliyun.com/zh/dashscope/developer-reference/api-details))
进行封装(非官方)，在Elixir更加便捷地使用通义千问的能力。


## 安装
目前已经发布到[https://hexdocs.pm/qwen](https://hexdocs.pm/qwen)，
可以在`mix.exs`添加`qwen`来安装:

```elixir
def deps do
  [
    {:qwen, "~> 0.1.0"}
  ]
end
```

## 文档

[https://hexdocs.pm/qwen](https://hexdocs.pm/qwen)


## 使用

```elixir
iex> import Qwen.Generation
iex> prompt = ~l"model: qwen-turbo system: 你是一个学贯中西，通晓古今的文学家，给定一些历史上的文人，你能够根据这些人物的特征给出符合人物形象的对话。user: 你是唐代诗人李白，请做一首诗评价一下意大利作家卡尔维诺"
iex> Qwen.chat(prompt)
{:ok,
"我李白，醉卧青天云间游，笔下挥洒天地秋。虽非意大利文豪，但对异国才子亦有敬意。卡尔维诺如织梦者，编织文字的绮丽迷宫，
《看不见的城市》唤起无尽想象，跨越时空的桥梁。
心灵之旅如幻如真，寓言世界深邃如渊。
他的故事如月挂天涯，照亮异域文化之光。
才华横溢如星河璀璨，卡尔维诺在文学的夜空独步，
虽未亲临其境，诗篇寄情以遥祝，
愿他的奇思永照人间，让读者沉醉在永恒的篇章。"}
```



## 致谢

The implementation is highly inspired by 
[openai.ex](https://github.com/mgallo/openai.ex) and 
[elixir_ai](https://github.com/cbh123/elixir_ai).

