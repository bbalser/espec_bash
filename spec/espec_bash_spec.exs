defmodule ESpec.Bash_Spec do
  use ESpec.Bash

  describe "Espec.Bash" do

    context "can execute a simple command" do

      before output: execute("pwd && exit 2")

      it "can execute a command and get stdout" do
        expect(shared.output.stdout) |> to(eq("#{System.cwd()}\n"))
      end

      it "can execute a command get return status" do
        expect(shared.output.status) |> to(eq(2))
      end

    end

    context "can setup a mock" do

      before do
        mock = bash_mock("pwd") |> outputs("/have/a/nice/day")
        result = execute("pwd")
        {:shared, mock: mock, result: result}
      end

      it "and stub output" do
        expect(shared.result.stdout) |> to(eq("/have/a/nice/day"))
      end

      it "and verify mock call" do
        expect(shared.mock) |> to(be_called([]))
      end

    end

    context "can mock a call with arguments" do

      before mock: bash_mock("pwd") |> outputs("/fake/dir", ["-a"])

      it "returns proper output" do
        result = execute("pwd -a")
        expect(result.stdout) |> to(eq("/fake/dir"))
      end

      it "and be verified" do
        execute("pwd -a")
        expect(shared.mock) |> to(be_called(["-a"]))
      end

      it "will not get proper output when called with wrong arguments" do
        result = execute("pwd -b")
        expect(result.stdout) |> to(eq(""))
      end

    end

    context "can execute a function call" do

      it "gets stdout" do
        result = execute_function("spec/stuff.sh", "ballin")
        expect(result.stdout) |> to(eq("Party all day!\n"))
      end

    end

  end

end
