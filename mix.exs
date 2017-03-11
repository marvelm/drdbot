defmodule Drd.Mixfile do
  use Mix.Project

  def project do
    [app: :drd,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: applications(Mix.env),
     mod: {Drd.Application, []}]
  end

  defp applications(:dev), do: applications(:all) ++ [:remix]
  defp applications(_all), do: [:logger, :httpoison]

  defp deps do
    [
      {:httpoison, "~> 0.11.0"},
      {:poison, "~> 3.1.0"},
      {:remix, "~> 0.0.1", only: :dev}
    ]
  end
end
