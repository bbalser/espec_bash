defmodule ESpec.Bash.Assertions.BeCalled do
  use ESpec.Assertions.Interface
  alias ESpec.Bash.Mock

  defp match(subject, data) do
    Mock.verify(subject, data)
  end

  defp success_message(subject, data, result, positive) do
    "call was matched #{to_string(subject)} #{Enum.join(data, " ")}"
  end

  defp error_message(subject, data, result, poasitive) do
  end

end
