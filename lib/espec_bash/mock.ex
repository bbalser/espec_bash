defmodule ESpec.Bash.Mock do

  def add_mock(mock) do
    atom = String.to_atom(mock)
    GenServer.cast(ESpec.Bash.Mock.Server, { :add, atom })
    atom
  end

  def outputs(mock, output, args \\ []) do
    GenServer.cast(ESpec.Bash.Mock.Server, { :stub, mock, output, args})
    mock
  end

  def invoke(mock, args \\ [], node \\ Node.self()) do
    GenServer.call({ESpec.Bash.Mock.Server, node}, { :invoke, mock, args })
  end

  def verify(mock, args \\ [], opts \\ []) do
    GenServer.call(ESpec.Bash.Mock.Server, { :verify, mock, args, opts })
  end

  def get_mocks() do
    GenServer.call(ESpec.Bash.Mock.Server, :get_mocks)
  end

  def clear() do
    GenServer.call(ESpec.Bash.Mock.Server, :clear)
  end

end
