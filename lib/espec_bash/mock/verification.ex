defmodule ESpec.Bash.Mock.Verifier do

  @spec verify(mock :: atom, args :: list, opts :: keyword, state :: map) :: { boolean, String.t}
  def verify(mock, args, opts, state) do
    info = %{mock: mock, args: args, opts: opts, invocations: get_in(state, [mock, :invocations])}

    determine_matched_invocations(info)
    |> check()
    |> create_message()
  end

  defp determine_matched_invocations(info_map = %{args: args, invocations: invocations}) do
    matched_list = Enum.filter(invocations, fn %{args: inv_args} -> all_arguments_match?(inv_args, args) end)
    Map.put(info_map, :matched_count, Enum.count(matched_list))
  end

  defp check(info = %{opts: opts, matched_count: count}) do
    times_matcher = Keyword.get(opts, :times, ESpec.AssertionHelpers.be(:>, 0))
    { argument_match?(count, times_matcher), Map.put(info, :times_matcher, times_matcher) }
  end

  defp create_message({true, _info}), do: {true, ""}
  defp create_message({false, %{mock: mock, times_matcher: times_matcher, invocations: invocations, args: args}}) do
    message = "Mock `#{mock}` did not match\n" <>
                "\texpected invocation: #{mock} #{print_matchers(args)}\n" <>
                "\texpected number of invocations: #{print_matcher(times_matcher)}\n" <>
                "\tactual invocations:\n" <>
                "\t\t#{print_invocations(mock, invocations)}\n"

    {false, message}
  end

  defp print_matchers(matchers) do
    matchers
    |> Enum.map(fn arg -> print_matcher(arg) end)
    |> Enum.join(" ")
  end

  defp print_matcher({module, expected}) when is_list(expected) do
    print_matcher({module, Enum.join(expected, " ")})
  end
  defp print_matcher({module, expected}), do: "(#{Macro.to_string(module)} #{expected})"
  defp print_matcher(times), do: times

  defp print_invocations(mock, invocations) do
    invocations
    |> Enum.reverse
    |> Enum.map(fn x -> x.args end)
    |> Enum.map(fn x -> "#{mock} #{Enum.join(x, " ")}" end)
    |> Enum.join("\n\t\t")
  end

  @spec all_arguments_match?(actual_args :: list, matched_arguments :: list) :: boolean
  def all_arguments_match?(actual, matched) when length(actual) != length(matched), do: false
  def all_arguments_match?(actual, matched) do
    Enum.zip(actual, matched)
    |> Enum.all?(fn {actual_arg, matched_arg} -> argument_match?(actual_arg, matched_arg) end)
  end

  defp argument_match?(actual_arg, {assertion_module, value}) do
    case is_assertion_module?(assertion_module) do
      true -> evaluate_assertion(assertion_module, actual_arg, value)
      false -> false
    end
  end
  defp argument_match?(actual_arg, matched_arg) when actual_arg == matched_arg, do: true
  defp argument_match?(_, _), do: false

  defp evaluate_assertion(module, subject, value) do
    try do
      apply(module, :assert, [subject, value, true])
      true
    rescue
      ESpec.AssertionError -> false
    end
  end

  defp is_assertion_module?(module) do
    Code.ensure_loaded?(module) && function_exported?(module, :assert, 3)
  end

end
