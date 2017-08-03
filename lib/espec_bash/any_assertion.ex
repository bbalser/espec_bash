defmodule ESpec.Assertions.Any do

  use ESpec.Assertions.Interface

  defp match(subject, value) do
    {true, value}
  end

  defp success_message(_subject, value, _result, _positive) do
    "`#{value}` always matches"
  end

  defp error_message(_subject, value, _result, _positive) do
    "`#{value}` always matches"
  end

end
