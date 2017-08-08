defmodule ESpec.Bash.Mock.CLI do

  @nodename :"mock@localhost"

  def main(args \\ []) do
    with {:ok, _pid} <- start_node(),
         {:ok} <- connect_to_server(),
         {mock, mock_args} <- parse_args(args),
         output <- record_invocation(mock, mock_args) do
         IO.write(output)
    else
      {:error, reason} -> handle_error(reason)
    end
  end

  defp record_invocation(mock, args) do
    GenServer.call({ESpec.Bash.Mock.Server, server()}, {:invoke, String.to_atom(mock), args})
  end

  defp parse_args([mock | args]) do
   {mock, args}
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
