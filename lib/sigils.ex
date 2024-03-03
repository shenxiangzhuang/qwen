defmodule Qwen.Sigils do
  @moduledoc """
  Qwen Generation
  """
  # sigil_l
  @doc """
  `sigil_l`(`~l""`, `～l`含义: *L*anguage): 利用Elixir的Sigil，按照一定格式输入字符串，自动解析为聊天/文本补全请求的格式


  ## 示例一: 一般用法
  只需要指定`model`和`system`, `user`即可。

  ```elixir
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
    lines |> text_to_chat_prompt()
  end

  @doc """
  `sigil_p`(`~p""`, `～p`含义: *P*icture): 利用Elixir的Sigil，按照一定格式输入字符串，自动解析为文生图请求需要的格式

  ## 示例
  ```
  iex> ~p"model: wanx-v1 prompt: 一只奔跑的猫 parameters.style: <chinese painting> parameters.size: 1024x1024 parameters.n: 1 parameters.seed: 42"
  [
    model: "wanx-v1",
    input: %{prompt: "一只奔跑的猫"},
    parameters: %{
      size: "1024x1024",
      seed: 42,
      n: 1,
      style: "<chinese painting>"
    }
  ]
  ```

  """
  def sigil_p(lines, _opts) do
    lines |> text_to_image_prompt()
  end

  defp text_to_image_prompt(text) when is_binary(text) do
    model = extract_model(text) |> String.trim()
    input = extract_image_prompt(text)
    # cast n, seed parameter to integer
    parameters =
      extract_parameters(text)
      |> cast_parameter_value_to_int(:n)
      |> cast_parameter_value_to_int(:seed)

    [model: model, input: input, parameters: parameters]
  end

  defp text_to_chat_prompt(text) when is_binary(text) do
    model = extract_model(text) |> String.trim()
    messages = extract_messages(text)
    parameters = extract_parameters(text)
    [model: model, input: %{messages: messages}, parameters: parameters]
  end

  @doc """
  Casts the value associated with the given key in the parameters map to an integer.

  ## Example

      iex> Qwen.Sigils.cast_parameter_value_to_int(%{a: "123", b: "456"}, :a)
      %{a: 123, b: "456"}

      iex> Qwen.Sigils.cast_parameter_value_to_int(%{a: "123", b: "456"}, :b)
      %{a: "123", b: 456}

      iex> Qwen.Sigils.cast_parameter_value_to_int(%{a: "123", b: "456"}, :c)
      %{a: "123", b: "456"}
  """
  def cast_parameter_value_to_int(parameters, key) do
    case Map.has_key?(parameters, key) do
      true -> %{parameters | key => Map.get(parameters, key) |> String.to_integer()}
      false -> parameters
    end
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

  defp extract_image_prompt(text) do
    keywords = ["prompt:", "negative_prompt:"]

    Enum.reduce_while(keywords, %{}, fn keyword, acc ->
      case extract_value_after_keyword(text, keyword) do
        nil ->
          {:cont, acc}

        value ->
          input_prompt = String.trim(keyword, ":")
          acc = Map.put(acc, String.to_atom(input_prompt), String.trim(value))
          {:cont, acc}
      end
    end)
  end

  defp extract_parameters(text) do
    keywords = ["result_format:", "style:", "size:", "n:", "seed:"]

    Enum.reduce_while(keywords, %{}, fn keyword, acc ->
      case extract_value_after_keyword(text, "parameters." <> keyword) do
        nil ->
          {:cont, acc}

        value ->
          param = String.trim(keyword, ":")
          acc = Map.put(acc, String.to_atom(param), String.trim(value))
          {:cont, acc}
      end
    end)
  end

  defp extract_value_after_keyword(text, keyword) do
    pattern = ~r/#{keyword}\s*(.*?)(?=model:|system:|user:|assistant:|prompt:|parameters.|$)/s

    case Regex.run(pattern, text) do
      [_, value] -> value
      _ -> nil
    end
  end
end
