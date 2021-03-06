defmodule ESpec.Bash.Assertions.BeCalled do
  use ESpec.Assertions.Interface
  alias ESpec.Bash.Mock

  defp match(subject, data) do
    Mock.verify(subject, data)
  end

  defp success_message(_subject, _data, result, _positive) do
    result
  end

  defp error_message(_subject, _data, result, _positive) do
    result
  end

end
