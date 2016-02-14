---
layout: post
title: "Elixir Best Practices - Pipe Everything"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: elixir, best practices, engineering
---

[Elixir's pipe operator][pipe] is incredibly powerful and quickly
becomes a favorite tool for developers new to the language. There are
situations where you may feel you cannot use the pipe operator, have to
save to temporary variables, to get what you want.

## Tuples

If you are piping functions and one of the functions returns a tuple,
but you just want one of the values in the tuple to pipe into the next
function you can use [`Kernel.elem/2`][elem].

Let's see what you might typically write:

```elixir
def parse_file(path) do
  {:ok, data} = File.read(path)
  parse_data(data)
end
```

Refactoring this to use pipes:

```elixir
def parse_file(path) do
  File.read(path)
  |> elem(1)
  |> parse_data()
end
```

While the contrived example here does lend itself
to having a refactor with one extra like it does force our code to
be more composable.

## Comparisons

Let's say you are writing a boolean function that checks to see if the current value
is equal to another value. You might write the following:

```elixir
def compat?(path, data) do
  content =
    File.read(path)
    |> elem(1)
    |> parse_content()

  content == data
end
```

Keep in mind that Elixir is built on Erlang, and in Erlang *everything*
is a function. Even the [comparison operators][comparison]. Knowing
this, we can refactor the above with `Kernel.==/2`:

```elixir
def compat?(path, data) do
  File.read(path)
  |> elem(1)
  |> parse_content()
  |> Kernel.==(data)
end
```

## Arithmetic

In situations where you must make an arithmetic operation on a value you
can still do this within a pipe. Similar to the comparisons above, keep
in mind that is Erlang everythig is a function. This time we'll use
[`Kernel.+/2`][add]:

```elixir
foobar
|> Kernel.+(1)
```

## Here be dragons

The last is more of a trick than something I think people should use,
but you can use an anonymous function to run anything through a pipe.

Let's refactor the equality comparison to use an anonymous function
instead:

```elixir
def compat?(path, data) do
  File.read(path)
  |> elem(1)
  |> parse_content()
  |> (&(&1 == data)).()
end
```

Again, this is not a trick you should use. But like everything I'm sure
there is a time and a place.

I won't suggest that you always rely on pipes or try to force pipes
when you shouldn't. However, when you do want to use pipes and think you
cannot Elixir usually provides a way.

[pipe]: http://elixir-lang.org/getting-started/enumerables-and-streams.html#the-pipe-operator
[elem]: http://elixir-lang.org/docs/stable/elixir/Kernel.html#elem/2
[comparison]: http://elixir-lang.org/docs/stable/elixir/Kernel.html#==/2
[add]: http://elixir-lang.org/docs/stable/elixir/Kernel.html#+/1
