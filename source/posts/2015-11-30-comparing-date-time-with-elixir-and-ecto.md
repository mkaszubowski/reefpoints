---
layout: post
title: "Comparing dates and times with Elixir using Ecto"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: elixir, phoenix, ecto
---

If you are working with `Ecto.DateTime` in your Phoenix
application you may make a comparison of two variables at some point:

```elixir
d1 = {{2015, 11, 30}, {0, 0, 0}} |> Ecto.DateTime.from_erl
d2 = {{2015, 11, 29}, {0, 0, 0}} |> Ecto.DateTime.from_erl

assert d1 > d2
```

The above ends up passing the assertion, but only by coincidence. What
if you had a situation where you wanted to assert a comparison between
today and tomorrow, but tomorrow ends up being a different month:

```elixir
d1 = {{2015, 12, 1}, {0, 0, 0}} |> Ecto.DateTime.from_erl
d2 = {{2015, 11, 30}, {0, 0, 0}} |> Ecto.DateTime.from_erl

assert d1 > d2
```

The above assertion fails. If you think it seems odd that `December 1, 2015`
would be less than `November 30, 2015` you'd be correct. To understand
why we have to see what `Ecto.DateTime.from_erl/1` returns:

```elixir
{{2015, 12, 1}, {0, 0, 0}} |> Ecto.DateTime.from_erl

# => #Ecto.DateTime<2015-11-30T00:00:00Z>
```

This is an [Elixir Struct][struct]. The properties of the struct are not
ordered, so the comparison does not actually understand the structure of
datetime and how to compare properly. In this case it appears that the
day values are being compared before the month values, resulting in a
`false` assertion. To better understand this we need to take a look at
the Erlang documentation for Maps (which are just Structs):

> Maps are ordered by size, two maps with the same size are compared by
> keys in ascending term order and then by values  in key order. In maps
> key order integers types are considered less than floats types.

To do a proper datetime comparison between two `Ecto.DateTime` structs we have to convert to a
tuple. We can do this by using `Ecto.DateTime.to_erl`:

```elixir
d1 = #Ecto.DateTime<2015-12-01T00:00:00Z>
d2 = #Ecto.DateTime<2015-11-30T00:00:00Z>

assert Ecto.DateTime.to_erl(d1) > Ecto.DateTime.to_erl(d2)
```

This can be cumbersome to write all the time. Thankfully Ecto comes with
a nice [`Ecto.DateTime.compare/2`][compare] function:

```elixir
d1 = #Ecto.DateTime<2015-12-01T00:00:00Z>
d2 = #Ecto.DateTime<2015-11-30T00:00:00Z>

assert Ecto.DateTime.compare(d1, d2) == :gt
```

`Ecto.DateTime.compare/2` takes two time structs and compares the first
to the second. The result will be `:eq`, `:lt`, or `:gt`.

[struct]: http://elixir-lang.org/getting-started/structs.html
[compare]: http://hexdocs.pm/ecto/Ecto.DateTime.html#compare/2
