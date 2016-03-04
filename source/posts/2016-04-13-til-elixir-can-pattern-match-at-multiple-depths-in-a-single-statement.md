---
layout: post
title: "TIL: Elixir can pattern match at multiple depths in a single statement"
author: "Marin Abernethy"
twitter: "pairinMarin"
github: "maabernethy"
published: true
tags: elixir, til
---

One of Elixir's greatest assets is its [pattern matching][matching-post]. If you have
ever used Elixir, you have probably had the pleasure of writing
something like:

```elixir
def background_check(%{manager: employee} = company) do
  %{name: full_name} = employee

  from(c in Criminals,
  where: c.full_name == ^full_name,
  select: c)
  |> Repo.one
  |> case do
    nil -> congratulate(employee)
    criminal -> notify(company)
  end
end
```

Here we are assigning the entire parameter map to a variable called
`company`, and pattern matching to get the `employee` we want to
do a background check on. We need to query our `Criminals` database
table for a `criminal` with the same name as our `employee`. To do so, we first have to grab
the `name` property off the `employee` object.

Well, **today I learned**, that you can have multiple matches in a
single statement! With this newly acquired knowledge, we can simplify
our `background_check()` function definition:

```elixir
def check_company(%{manager: %{name: full_name} = employee} = company) do
  from(c in Criminals,
  where: c.full_name == ^full_name,
  select: c)
  |> Repo.one()
  |> case do
    nil -> congratulate(employee)
    criminal -> notify(company)
  end
end
```

Now we can pattern match to get the `employee`'s `full_name`, while also
assigning the entire map under the `manager` key to the variable `employee`, as we did before.

Hopefully, you learned something too! Enjoy.

[matching-post]: https://dockyard.com/blog/2014/12/26/pattern-matching-in-elixir-for-rubyists
