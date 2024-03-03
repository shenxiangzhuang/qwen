defmodule Qwen.MixProject do
  use Mix.Project

  @version "0.2.0"
  @description "Elixir ❤️ 通义千问"

  def project do
    [
      app: :qwen,
      version: @version,
      elixir: "~> 1.15",
      name: "Qwen",
      description: @description,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/shenxiangzhuang/qwen",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Xiangzhuang Shen"],
      links: %{"GitHub" => "https://github.com/shenxiangzhuang/qwen"}
    }
  end
end
