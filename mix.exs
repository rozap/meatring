defmodule Meatring.Mixfile do
  use Mix.Project

  def project do
    [app: :meatring,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end



  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {Meatring, []},
      applications: [:logger]
    ]
  end

  defp deps do
    [
      {:exkad, git: "https://github.com/rozap/exkad.git"},
      {:plug, "~> 0.8.2"},
      {:poison, "~> 1.2.0"},
      {:httpotion, "~> 0.2.0"},
    ]
  end
end
