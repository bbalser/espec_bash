defmodule StuffSpec do
  use ESpec.Bash

  it do: expect true |> to(be_true())
  it do: expect(2) |> to(eq(2))

  it "Stuff test" do
    #mock = bash_mock("pwd")
    #outputs(mock, "Hello", ["-a"])
    #output = execute("pwd")
    #    expect(mock) |> to(be_called([be_true(), { 1, eq("stuff") } ], times: be(:>, 2)) #unordered
    #    expect(mock) |> to(be_called({ be_true(),  2, eq("stuff")  }, times: 2) #ordered
    #
    #    expect(mock) |> to(be_called(["-a", { "-n", "jerks" }])
    #
    #
    #pwd -a -n jerks
    #pwd -n jerks -a
  end

  #it "executes stuff" do
  #  x = execute("pwd")
  #  expect(x.stdout) |> to(eq("pwd"))
  #end

  #it "executes functions" do
  #  x = execute_function("./stuff.sh", "ballin")
  #  expect(x.stdout) |> to(eq("ballin"))
  #end

end
