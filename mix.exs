defmodule EspecBash.Mixfile do
  use Mix.Project

  def project do
    [app: :espec_bash,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: [espec: :test],
     escript: escript(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {ESpec.Bash.Application, []}]
  end

  def escript do
    [
      main_module: ESpec.Bash.Mock.CLI,
      app: nil,
    ]
  end

  defp deps do
    [
      { :mix_test_watch, "~> 0.4.1", only: :dev, runtime: false },
      { :dialyxir, "~> 0.5.1", only: [:dev], runtime: false },
      { :espec, "~> 1.4.5" },
    ]
  end
end
