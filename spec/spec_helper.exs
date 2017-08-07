ESpec.configure fn(config) ->

  EspecBash.Application.ensure_distributed_node()

  config.before fn(tags) ->
    Code.require_file("spec/assertions/fake.ex")
    {:shared, hello: :world, tags: tags}
  end

  config.finally fn(_shared) ->
    :ok
  end
end
