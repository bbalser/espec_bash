defmodule ESpec.Bash do

  alias ESpec.Bash.Mock
  alias ESpec.Bash.Return
  @bash "bash"
  @proxy_path System.cwd() |> Path.join("espec_bash")

  defmacro __using__(_opts) do
    quote do
      use ESpec
      import ESpec.Bash
    end
  end

  defdelegate bash_mock(command), to: Mock, as: :add_mock

  defdelegate outputs(command, output, args \\ []), to: Mock

  def execute(command) do
    with_mock_file(fn mock_file ->
      { stdout, status } = "source #{mock_file} && #{command}" |> execute_bash_command()
      %Return{stdout: stdout, status: status}
    end)
  end

  def execute_function(script, function) do
    { stdout, status } = "source #{script} && #{function}" |> execute_bash_command()
    %Return{stdout: stdout, status: status}
  end

  #def execute_function(script, function) do
  #  helper_file = create_mock_function(function)
  #  command = "source #{script} && source #{helper_file} && #{function}"
  #  { stdout, status } = System.cmd(@bash, ["-c", command])
  #  %ESpec.Bash.Return{stdout: String.trim(stdout), status: status }
  #end

  def any(), do: {ESpec.Assertions.Any, ""}
  def be_called(args), do: {ESpec.Bash.Assertions.BeCalled, args}

  defp with_mock_file(func) when is_function(func) do
    mock_file = Mock.get_mocks() |> create_mock_file()
    output = func.(mock_file)
    File.rm!(mock_file)
    output
  end

  defp execute_bash_command(command) do
    System.cmd(@bash, ["-c", command])
  end

  defp create_mock_file(commands) do
    content = Stream.map(commands, &bash_function_string/1)
              |> Enum.join("\n")

    make_helper_path()
    |> write_helper_file(content)
  end

  defp bash_function_string(command) do
    """
    function #{command} {
      #{@proxy_path} #{command} "$@"
    }
    export -f #{command}
    """
  end

  defp make_helper_path() do
    path = System.cwd() |> Path.join(".espec_bash")
    File.mkdir_p!(path)
    path
  end

  defp write_helper_file(dir, content) do
    helper_file = Path.join([dir, "helper"])
    File.write!(helper_file, content)
    helper_file
  end

end
