---
layout: post
title: "Elixir Best Practices - Deeply Nested Maps"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: elixir, best practices
---

When writing Elixir apps you'll typically find yourself building up
state in a [map][map]. Typically these maps contain deep 
nesting. Updating anything deeply nested means you have to write something like:

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
Elixir has a better way: [`Kernel.put_in/3`][put_in_3]

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
argument is simply a list which means when we're dealing building
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

Let's go deeper. Does the list syntax feel like too many characters to
you? Let me introduce you to [`Kernel.put_in/2`][put_in_2]

```elixir
put_in(my_map.foo.bar.baz, "new value")
```

This version of the function is a [macro that will break up the syntax
and deal with each part of the path individually][put_in_2_macro]. It may feel like
magic but it's just Elixir doing what it does best: blowing your mind.

Still going deeper...

Now its time to get fancy. Let's say you want to update the values
according to a function. To do that we'll use
[`Kernel.update_in/3`][update_in_3]

```elixir
my_map = %{
  bob: %{
    age: 36
  }
}

update_in(my_map, [:bob, :age], &(&1 + 1))
#=> %{bob: %{age: 37}}

update_in(my_map.bob.age, &(&1 + 1))
#=> %{bob: %{age: 37}}
```

### Dealing with Lists and Structs

Deeply nested lists can also make use of these functions. However, there
is a difference in the short-hand syntax.

```elixir
my_list = [foo: [bar: [baz: "my value"]]]

put_in(my_list[:foo][:bar][:baz], "new value")
```

This is referred to as "[field-based lookup][field-lookup]" and can
differ depending upon the type you are acting upon. Maps can work with
either form:

```elixir
my_map[:foo][:bar][:baz]
#=> "my value"

my_map.foo.bar.baz
#=> "my value"
```

Lists only work with the bracket form:

```elixir
my_list[:foo][:bar][:baz]
#=> "my value"

my_list.foo.bar.baz
#=> ** (ArgumentError) argument error
```

Structs only work with the path form:

```elixir
my_struct.foo.bar.baz
#=> "my value"

my_struct[:foo][:bar][:baz]
#=>  ** (UndefinedFunctionError) undefined function MyStruct.fetch/2
```

I hope this helps you deal with deeply nested maps, lists, and structs!

[map]: http://elixir-lang.org/getting-started/keywords-and-maps.html
[merge]: http://elixir-lang.org/docs/stable/elixir/Map.html#merge/2
[put_in_3]: http://elixir-lang.org/docs/stable/elixir/Kernel.html#put_in/3
[put_in_2]: http://elixir-lang.org/docs/stable/elixir/Kernel.html#put_in/2
[put_in_2_macro]: https://github.com/elixir-lang/elixir/blob/v1.2.2/lib/elixir/lib/kernel.ex#L1831-L1839
[access]: http://elixir-lang.org/docs/stable/elixir/Access.html
[update_in_3]: http://elixir-lang.org/docs/stable/elixir/Kernel.html#update_in/3
[field-lookup]: https://github.com/elixir-lang/elixir/blob/v1.2.2/lib/elixir/lib/access.ex#L50
