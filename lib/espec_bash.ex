defmodule ESpec.Bash do

  alias ESpec.Bash.Mock
  @bash "bash"

  defmacro __using__(_opts) do
    quote do
      use ESpec
      import ESpec.Bash
    end
  end

  def bash_mock(command) do
    Mock.add_mock(command)
  end

  defdelegate outputs(command, output, args \\ []), to: Mock

  def execute(command) do
    helper_path = create_mock_function(command)
    command_with_helper = "source #{helper_path} && #{command}"
    { stdout, status } = System.cmd(@bash, ["-c", command_with_helper])
    %ESpec.Bash.Return{stdout: String.trim(stdout), status: status }
  end

  def execute_function(script, function) do
    helper_file = create_mock_function(function)
    command = "source #{script} && source #{helper_file} && #{function}"
    { stdout, status } = System.cmd(@bash, ["-c", command])
    %ESpec.Bash.Return{stdout: String.trim(stdout), status: status }
  end

  def any(), do: {ESpec.Assertions.Any, ""}
  def be_called(args), do: {ESpec.Bash.Assertions.BeCalled, args}

  defp create_mock_function(command) do
    content = """
    function #{command} {
      echo "#{command}"
    }
    export -f #{command}
    """

    make_helper_path()
    |> write_helper_file(content)
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
