defmodule ESpec.Bash.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  @node_name :"espec@localhost"

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(ESpec.Bash.Mock.Server, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ESpec.Bash.Mock.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def ensure_distributed_node() do
    if node() != @node_name do
      Node.start(@node_name, :shortnames)
    end
  end

  def node_name() do
    @node_name
  end

end
