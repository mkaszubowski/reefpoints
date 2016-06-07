---
layout: post
title: "TIL: Elixir pattern matching for argument equality"
summary: "pattern matching versus guard expressions"
social: true
author: Marin Abernethy
twitter: "pairinMarin"
github: maabernethy
published: true
tags: til, elixir
---

[Pattern matching][pattern-matching] and [guard expressions][guard-expressions] are fundamental to
writing recursive function definitions in [Elixir][elixir]. Sometimes guard clauses and pattern matching
can be used for the same purpose. For example:

```elixir
# pattern matching
defmodule Exponent do
  def power(value, 0), do: 1
  def power(value, n), do: value * power(value, n - 1)
end

# guard expression
defmodule Exponent do
  def power(value, n) when n == 0, do: 1
  def power(value, n), do: value * power(value, n - 1)
end
```

In both cases above, we only want the first `power` function to run when the second argument is equal to `0`.
When it is as simple as equality, I tend to use the pattern matching syntax. I typically leave the guard for more complex
logic like `when rem(x, divisor) == 0`. However, to check whether one argument is equal to another I thought a guard was neccessary: `when a == b`.
But, **today I learned**, this can also be handled with pattern matching, like so:

```elixir
# guard
def equality(a, b) when a == b, do: IO.puts "equal"
def equality(a, b), do: IO.puts "not equal"

# pattern matching
def equality(a, a), do: IO.puts "equal"
def equality(a, b), do: IO.puts "not equal"
```

Tada! There you have it. It seems so simple I don't know how I hadn't tried it earlier!

[pattern-matching]: http://elixir-lang.org/getting-started/pattern-matching.html
[guard-expressions]: http://elixir-lang.org/getting-started/case-cond-and-if.html#expressions-in-guard-clauses
[elixir]: http://elixir-lang.org/
