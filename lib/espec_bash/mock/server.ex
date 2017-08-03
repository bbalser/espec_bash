defmodule ESpec.Bash.Mock.Server do

  alias ESpec.Bash.Mock.Verifier

  use GenServer
  @me __MODULE__

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: @me)
  end

  def init(_args) do
    {:ok, %{} }
  end

  def handle_cast({ :add, mock }, state) do
    Map.put(state, mock, %{stubs: [], invocations: []})
    |> noreply()
  end

  def handle_cast({ :stub, mock, output, args }, state) do
    stub = %{args: args,  output: output}
    update_in(state, [mock, :stubs], fn stubs -> [ stub | stubs] end)
    |> noreply()
  end

  def handle_call({ :invoke, mock, args }, _from, state) do
    output = get_in(state, [mock, :stubs])
    |> Enum.find(fn %{args: stub_args} -> Verifier.all_arguments_match?(args, stub_args) end)

    new_state = update_in(state, [mock, :invocations], fn invs -> [%{args: args} | invs] end)
    reply(output, new_state)
  end

  def handle_call({ :verify, mock, args, opts}, _from, state) do
    Verifier.verify(mock, args, opts, state)
    |> reply(state)
  end

  def handle_call(:clear, _from, _state) do
    reply(:ok, %{})
  end

  defp reply(%{output: output}, state), do: { :reply, output, state }
  defp reply(output, state), do: { :reply, output, state }

  defp noreply(state), do: { :noreply, state }

end
