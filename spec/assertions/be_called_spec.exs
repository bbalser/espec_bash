defmodule ESpec.Bash.Assertions.Be_Called_Spec do
  alias ESpec.Bash.Mock
  use ESpec.Bash

  describe "be_called" do

    let pwd: bash_mock("pwd")

    it "should pass when an invocation is matched" do
      outputs(pwd(), "/jerks", ["-a"])
      Mock.invoke(pwd(), ["1"])
      output = Mock.invoke(pwd(), ["-a"])
      expect(pwd()) |> to(be_called(["-a"]))
      expect(output) |> to(eq("/jerks"))
    end

    it "should fail when no invocation is matched" do
      message = try do
        expect(pwd()) |> to(be_called(["-a"]))
        :fail
      rescue
        e in ESpec.AssertionError -> e.message
      end

      expect(message) |> to(eq(
        "Mock `pwd` did not match\n" <>
          "\texpected invocation: pwd -a\n" <>
          "\texpected number of invocations: (ESpec.Assertions.Be > 0)\n" <>
          "\tactual invocations:\n\t\t\n"))
    end


  end

end
