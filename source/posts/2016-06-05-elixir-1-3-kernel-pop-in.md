---
layout: post
title: "New to Elixir 1.3 - Kernel.pop_in"
summary: "Working with large objects just became easier"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: elixir, engineering
---

Back in February I wrote about [how to work with deeply nested
maps][deepmaps]. One missing piece was the ability to easily prune data
from a deeply nested map. Today I'd like to introduce you to
`Kernel.pop_in` which will be available in Elixir 1.3.

Given the following:

```elixir
my_map = %{
  foo: %{
    bar: %{
      baz: "my value"
    }
  }
}
```

In order to delete the `baz` atom you would have to write something like
this:

```elixir
put_in(my_map, [:foo, :bar], %{})
```

For this contrite example it may not seem that bad. But let's take a
look at another example:

```elixir
my_map = %{
  foo: %{
    bar: %{
      baz: "my value",
      qux: "other value"
    }
  }
}
```

If we wanted to preserve the `qux` atom we'd write:

```elixir
put_in(my_map, [:foo, :bar], Map.delete(my_map[:foo][:bar], :baz))
```

Now we're starting to see something that could get ugly. This is where
`Kernel.pop_in` can help:

```elixir
pop_in(my_map, [:foo, :bar, :baz])
```

That's nice and clean! However, unlike the other accessor-based
functions this one returns a tuple:

```elixir
{"my value", %{foo: %{bar: %{qux: "other value"}}}} = pop_in(my_map, [:foo, :bar, :baz])
```

The first element in the tuple will be the value that is being removed.
The second element will be the new map.

Elixir 1.3 comes packed with a bunch of improvements for the developer
experience like this one. Hopefully we can all start enjoying it soon!

[deepmaps]: https://dockyard.com/blog/2016/02/01/elixir-best-practices-deeply-nested-maps
