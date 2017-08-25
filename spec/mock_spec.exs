defmodule ESpec.Bash.MockSpec do
  use ESpec
  alias ESpec.Bash.Mock
  alias ESpec.Assertions.Fake

  describe "ESpec.Bash.Mock.Server" do

    finally do: GenServer.call(ESpec.Bash.Mock.Server, :clear)

    describe "outputs" do

      let mock: Mock.add_mock("pwd")

      it "should match a simple invocation" do
        output = Mock.outputs(mock(), "Hello")
                 |> Mock.invoke
        expect(output) |> to(eq("Hello"))
      end

      it "should use arguments to match invocation" do
        output = Mock.outputs(mock(), "All", ["-a"])
                 |> Mock.outputs("Hello", ["-h"])
                 |> Mock.invoke(["-a"])
        expect(output) |> to(eq("All"))
      end

      context "leverages espec matchers" do

        before true_pid: Fake.create(true), false_pid: Fake.create(false)
        finally do
          Fake.stop(shared.true_pid)
          Fake.stop(shared.false_pid)
        end

        it "when matching arguments" do
          output = Mock.outputs(mock(), "Good", [Fake.assertion(shared.true_pid), "-a"])
                   |> Mock.outputs("Bad", [Fake.assertion(shared.false_pid), "-a"])
                   |> Mock.invoke([true, "-a"])

          expect(output) |> to(eq("Good"))
          expect(Fake.called(shared.true_pid)) |> to(eq(1))
          expect(Fake.called(shared.false_pid)) |> to(eq(1))
        end

      end

    end

    describe "verify" do

      let mock: Mock.add_mock("pwd")

      it "should pass if invoked" do
        Mock.invoke(mock())
        Mock.verify(mock())
      end

      it "should fail if not invoked" do
        {result, _message} = Mock.verify(mock())
        expect(result) |> to(be_false())
      end

      it "should match arguments when verifying invocation" do
        Mock.invoke(mock(), ["-a", "-b"])
        Mock.verify(mock(), ["-a", "-b"])
      end

      it "should fail if arguments do not match" do
        Mock.invoke(mock(), ["-x", "-m"])
        {result, _message} = Mock.verify(mock(), ["-a", "-b"])
        expect(result) |> to(be_false())
      end

      it "should fail if arguments and expected arguments are not the same length" do
        Mock.invoke(mock(), ["-a", "-x", "-y"])
        {result, _message} = Mock.verify(mock(), ["-a"])
        expect(result) |> to(be_false())
      end

      it "should fail when invoked twice but asked to verify 1 invocation" do
        Mock.invoke(mock(), [true, 1])
        Mock.invoke(mock(), [false, 1])
        {result, _message} = Mock.verify(mock(), [ESpec.Bash.any(), 1], times: 1)
        expect(result) |> to(be_false())
      end

      context "leverages espec matchers" do

        before fake_pid: Fake.create("-m")
        finally do: Fake.stop(shared.fake_pid)

        it "verify should leverage espec matchers" do
          Mock.outputs(mock(), "Good", ["-m", "-a"])
          |> Mock.outputs("Bad", ["-b", "-z"])
          |> Mock.invoke(["-m", "-a"])

          Mock.verify(mock(), [Fake.assertion(shared.fake_pid), "-a"])
          expect(Fake.called(shared.fake_pid)) |> to(eq(1))
        end

      end

      it "should report how many times it was called when times expectation is not met" do
        {_result, message} = Mock.verify(mock(), [], times: 1)
        expect(message) |> to(eq(
              "Mock `pwd` did not match\n" <>
                "\texpected invocation: pwd \n" <>
                "\texpected number of invocations: 1\n" <>
                "\tactual invocations:\n\t\t\n"))
      end

      it "should report number of invocations properly when espec matcher is used" do
        Mock.invoke(mock())
        Mock.invoke(mock())
        {_result, message} = Mock.verify(mock(), [], times: be(:>, 3))
        expect(message) |> to(eq(
              "Mock `pwd` did not match\n" <>
                "\texpected invocation: pwd \n" <>
                "\texpected number of invocations: (ESpec.Assertions.Be > 3)\n" <>
                "\tactual invocations:\n\t\tpwd \n\t\tpwd \n"))
      end

      it "should report espec assertions with only 3 argument with nice output" do
        {_result, message} = Mock.verify(mock(), [], times: eq(5))
        expect(message) |> to(eq(
              "Mock `pwd` did not match\n" <>
                "\texpected invocation: pwd \n" <>
                "\texpected number of invocations: (ESpec.Assertions.Eq 5)\n" <>
                "\tactual invocations:\n\t\t\n"))
      end

      it "should display all invocations against the mock when match fails" do
        Mock.invoke(mock(), ["-a", "fred"])
        Mock.invoke(mock(), ["-b", "barney"])
        {_result, message} = Mock.verify(mock(), [], times: 1)
        expect(message) |> to(eq(
          "Mock `pwd` did not match\n" <>
              "\texpected invocation: pwd \n" <>
              "\texpected number of invocations: 1\n" <>
              "\tactual invocations:\n" <>
              "\t\tpwd -a fred\n" <>
              "\t\tpwd -b barney\n"))
      end

      it "should display all the arguments expected as well" do
        Mock.invoke(mock(), ["--apples", "-bananas"])
        {_result, message} = Mock.verify(mock(), ["--aples", ESpec.AssertionHelpers.eq("--bananas")])
        expect(message) |> to(eq(
          "Mock `pwd` did not match\n" <>
            "\texpected invocation: pwd --aples (ESpec.Assertions.Eq --bananas)\n" <>
            "\texpected number of invocations: (ESpec.Assertions.Be > 0)\n" <>
            "\tactual invocations:\n" <>
            "\t\tpwd --apples -bananas\n"))
      end

    end

    describe "get_mocks" do

      it "should return all mocks" do
        Mock.add_mock("pwd")
        Mock.add_mock("./bin/ls")
        mocks = Mock.get_mocks()
        expect(mocks) |> to(have_length(2))
        expect(mocks) |> to(have(:pwd))
        expect(mocks) |> to(have(:"./bin/ls"))
      end

    end

  end

end
