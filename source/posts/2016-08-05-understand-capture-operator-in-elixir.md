---
layout: post
title: "Understanding the & (capture operator) in Elixir"
summary: "how to use & (capture operator) in Elixir"
author: "Daniel Xu"
twitter: "Daniel_Xu_For"
github: "Daniel-Xu"
published: true
tags: Elixir
---

# Understanding the & (capture operator) in Elixir

`&` is the capture operator in Elixir, it is used to **capture** and **create** anonymous functions.

## Anonymous functions and arity

Before going into details about the capture operator, let's get familiar with `anonymous functions` and `arity` first.

Given the following example:

```elixir
add_one = fn x -> x + 1 end
```
we defined a function, but it isn't bound to a global name, so it is an anonymous functions or a lambda.

This function takes one argument, so its arity is 1.

## How to use `&`

### capture function

Let's first talk about capturing function.
Capture means `&` can turn a function into an `anonymous functions ` which can be passed as arguments to other function or be bound to a variable.

`&` can capture two types of functions:

* function with given name and arity from a module

The notation is: `&(module_name.function_name/arity)`, e.g.

```elixir
speak = &(IO.puts/1)
speak.("hello")  # hello
```

We capture `puts` function from `IO` module and bind it with a local name `speak`.

* local function

In the following example, `put_in_columns` and `put_in_one_row` are defined in the same module, so we can capture `put_in_one_row` by
`&put_in_one_row/1`, notice that we don't include the module name here.

```elixir
defmodule Issues.TableFormatter do
  def put_in_columns(data_by_columns, format) do
	 Enum.each(data_by_columns, &put_in_one_row/1)
  end

  def put_in_one_row(fields) do
  	 # Do some things...
  end
end
```

### create anonymous functions

The capture operator can also be used to create anonymous functions, for example:

```elixir
add_one = &(&1 + 1)
add_one.(1) # 2
```

is the same with:

```elixir
add_one = fn x -> x + 1 end
add_one.(1) # 2
```

You might notice that `&1` is used in the above example. That's called a value placeholder, and it identifies the `nth` argument of the function

In addition, as `{}` and `[]` are also operators in Elixir, `&` can work with them too.

```elixir
return_list = &[&1, &2]
return_list.(1, 2) # [1, 2]

return_tuple = &{&1, &2}
return_tuple.(1, 2) # {1, 2}
```

It's hard to comprehend at first, we just need to think about it from another perpective:

![Alt text](https://monosnap.com/file/RfDoLHTqzOzGGXetAoUfUvVwPpAf5j.png)
