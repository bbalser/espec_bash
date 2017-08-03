defmodule ESpec.Bash.Mock do

  @spec add_mock(mock :: String.t) :: atom
  def add_mock(mock) do
    atom = String.to_atom(mock)
    GenServer.cast(ESpec.Bash.Mock.Server, { :add, atom })
    atom
  end

  @spec outputs(mock :: atom, output :: String.t, args :: list) :: atom
  def outputs(mock, output, args \\ []) do
    GenServer.cast(ESpec.Bash.Mock.Server, { :stub, mock, output, args})
    mock
  end

  @spec invoke(mock :: atom, args :: list) :: String.t
  def invoke(mock, args \\ []) do
    GenServer.call(ESpec.Bash.Mock.Server, { :invoke, mock, args })
  end

  @spec verify(mock :: atom, args :: list, opts :: keyword) :: nil
  def verify(mock, args \\ [], opts \\ []) do
    GenServer.call(ESpec.Bash.Mock.Server, { :verify, mock, args, opts })
  end

end
