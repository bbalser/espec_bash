defmodule ESpec.Bash.Mock.CLI do

  @nodename :"mock@localhost"

  def main([]), do: IO.puts("You did something stupid")
  def main([mock | args]) do
    with {:ok, _pid}        <- start_node(),
         {:ok}              <- connect_to_server(),
         output             <- record_invocation(mock, args) do
                            IO.write(output)
    else
      {:error, reason} -> handle_error(reason)
    end
  end

  defp record_invocation(mock, args) do
    GenServer.call({ESpec.Bash.Mock.Server, server()}, {:invoke, String.to_atom(mock), args})
  end

  defp start_node() do
    Node.start(@nodename, :shortnames)
  end

  defp connect_to_server() do
    case Node.connect(server()) do
      true -> {:ok}
      false -> {:error, "Unable to connect to #{server()}"}
    end
  end

  defp server() do
    ESpec.Bash.Application.node_name()
  end

  defp handle_error(reason) when is_binary(reason) do
    IO.puts(reason)
  end

end
