ESpec.configure fn(config) ->
  config.before fn(tags) ->
    Code.require_file("spec/assertions/fake.ex")
    {:shared, hello: :world, tags: tags}
  end

  config.finally fn(_shared) ->
    :ok
  end
end
