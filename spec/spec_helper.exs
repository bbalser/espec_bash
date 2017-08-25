ESpec.configure fn(config) ->

  ESpec.Bash.Application.ensure_distributed_node()

  config.before fn(tags) ->
    Code.require_file("spec/assertions/fake.ex")
    {:shared, hello: :world, tags: tags}
  end

  config.finally fn(_shared) ->
    ESpec.Bash.Mock.clear()
    :ok
  end
end
