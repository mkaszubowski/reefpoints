---
layout: post
title: "TIL: Elixir maps have built in syntax for updating"
author: "Marin Abernethy"
twitter: "pairinMarin"
github: "maabernethy"
published: true
tags: elixir, til
---

I am relatively new to Elixir and often find there are numerous ways to
implement a single task. For example, when I want to update a key value in a map, I have several options before me...

Given, `expenses = %{groceries: 200, rent: 1000, commute: 70}`, I could
employ:

* [`Map.merge(map1, map2)`][merge] if I want to update multiple key value pairs
and/or several new ones

```elixir
Map.merge(expenses, %{
  rent: 1200,
  comcast: 100
})
```

* [`Map.put(map, key, val)`][put] if updating or adding a single key value

```elixir
Map.put(expenses, :booze, 100)
```

* [`Map.update(map, key, initial, fun)`][update]: if I want to increment a value by a certain degree

```elixir
Map.update(expenses, :misc, 300, &(&1 * 2))
```

* [`Kernel.put_in(data, keys, value)`][put_in]: if I want to update a value in a nested structure

```elixir
expenses = %{groceries: %{milk: 5}, apartment: %{rent: 1000, comcast: 100}}
put_in(expenses, [:rent, :comcast], "too much")
```

However, **today I learned**, maps come with a built in syntax for updating
one or more key values!

```elixir
 %{expenses | groceries: 150, commute: 75}
```

While a bit obscure, and not easily found in the [elixir docs][docs], this trick is definitely nice to have in my elixir tool belt. The only thing to remember is that this syntax requires `groceries` and `commute`
to already exist. Otherwise, it will fail with an error. Hopefully, this syntax comes in handy for you now too!

If you want to know more about how to deal with nested structures, check out Brian's post ["Elixir Best Practices - Deeply Nested Maps"][brian]!

[merge]: http://elixir-lang.org/docs/stable/elixir/Map.html#merge/2
[put]: http://elixir-lang.org/docs/stable/elixir/Map.html#put/3
[update]: http://elixir-lang.org/docs/stable/elixir/Map.html#update/4
[put_in]: http://elixir-lang.org/docs/stable/elixir/Kernel.html#put_in/3
[docs]: http://elixir-lang.org/docs.html
[brian]: https://dockyard.com/blog/2016/02/01/elixir-best-practices-deeply-nested-maps
