defmodule EspecBash.Mixfile do
  use Mix.Project

  def project do
    [app: :espec_bash,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: [espec: :test],
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {EspecBash.Application, []}]
  end

  defp deps do
    [
      { :mix_test_watch, "~> 0.3", only: :dev, runtime: false },
      { :dialyxir, "~> 0.5.1", only: [:dev], runtime: false },
      { :espec, "~> 1.4.1" },
    ]
  end
end
