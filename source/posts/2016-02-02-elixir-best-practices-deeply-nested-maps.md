---
layout: post
title: "Elixir Best Practices - Deeply Nested Maps"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: elixir
---

When writing Elixir apps you'll typically find yourself building up
state in a [map][map]. For example, in Phoenix we have the `conn` map.
Typically these maps contain deep nesting. Updating anything deeply
nested means you have to write some like:

```elixir
my_map = %{
  foo: %{
    bar: %{
      baz: "my value"
    }
  }
}

new_bar_map =
  my_map
  |> Map.get(:foo)
  |> Map.get(:bar)
  |> Map.put(:baz, "new value")

new_foo_map =
  my_map
  |> Map.get(:foo)
  |> Map.put(:bar, new_bar_map)

Map.put(my_map, :foo, new_foo_map)
```

That's pretty complex for a simple nested key update!

Because of the immutable nature of Elixir, whenever we simply cannot
update inplace. You can clean this up a bit by using
[`Map.merge/2`][merge]:

```elixir
# [TODO] merge example
```

Elixir has a better way: [`Kernel.put_in/3`][put_in]

This function uses the [Access][access] "behaviour" to drastically
reduce the keystrokes for inserting into deeply nested maps. Let's take
a look at refactoring the above example:

```elixir
my_map = %{
  foo: %{
    bar: %{
      baz: "my value"
    }
  }
}

put_in(my_map, [:foo, :bar, :baz], "new value")
```

That's it! The really nice thing about this function is that the 2nd
argument is simply a list. Which means when we're dealing building
complex maps during recursion we can simply append to the list.

Similarly, we can get deeply nested values in a map using
`Kernel.get_in/2`:

```elixir
my_map = %{
  foo: %{
    bar: %{
      baz: "my value"
    }
  }
}

get_in(my_map, [:foo, :bar, :baz]) == "my value"
```

This should cut down on your code quite a bit!

[map]: http://elixir-lang.org/getting-started/keywords-and-maps.html
[merge]: http://elixir-lang.org/docs/stable/elixir/Map.html#merge/2
[put_in]: http://elixir-lang.org/docs/stable/elixir/Map.html#merge/2
[access]: http://elixir-lang.org/docs/stable/elixir/Access.html
