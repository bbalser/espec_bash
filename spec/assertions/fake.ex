defmodule ESpec.Assertions.Fake do

  use ESpec.Assertions.Interface

  defp match(subject, pid) do
    result = Agent.get_and_update(pid, fn state ->
      subjects = [ subject | state.subjects ]
      {subject == state.expected_value, %{ state | subjects: subjects, called: state.called + 1 }}
    end)
    {result, pid}
  end

  defp success_message(_subject, value, _result, _positive) do
    value_str = :erlang.pid_to_list(value) |> to_string
   "success - Fake Assertions was called with #{value_str}"
  end

  defp error_message(_subject, value, _result, _positive) do
    value_str = :erlang.pid_to_list(value) |> to_string
   "error - Fake Assertion was called with #{value_str}"
  end

  def create(expected_value) do
    {:ok, pid} = Agent.start_link(fn -> %{called: 0, subjects: [], expected_value: expected_value} end)
    pid
  end

  def assertion(pid) do
    {ESpec.Assertions.Fake, pid}
  end

  def called(pid), do: Agent.get(pid, fn state -> state.called end)

  def stop(pid), do: Agent.stop(pid)

end
