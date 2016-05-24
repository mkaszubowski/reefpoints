---
layout: post
title: "TIL: Ecto supports a query inside another query"
social: true
author: Marin Abernethy
twitter: "pairinMarin"
github: maabernethy
published: true
tags: ecto, elixir, til
---

If you read the [Ecto.Query][ecto-query] documentation, one of the first sections explains how
Ecto queries are composable. Meaning, we can extend a query after creating it. Like so:

```elixir
query = from e in Event,
  where: e.category == ^event.category

case event.host do
  host -> from e in query, where: e.host == ^host
  _ -> query
end
```

This was a feature that I learned a while after starting Elixir (apparently I didn't read the docs well enough).
And it is totally awesome. But **today I learned** Ecto also supports nested queries!

```elixir
last_event = from e in Event,
  distinct: e.id,
  order_by: [desc: e.inserted_at]

query = from a in Attendee, preload: [events: ^last_event]
```
Here, we are referencing a query (`last_event`) from within another query. How exciting! It is also important to mention
that Ecto 2.0 supports [subqueries][subqueries] in the `from` and `join` fields (see example below). This makes queries even more malleable and powerful.
Hope you enjoy it as much as I do!

```elixir
query = from e in Event, select: e
q = from e in subquery(query), select: e.summary
```

[ecto-query]: https://hexdocs.pm/ecto/Ecto.Query.html
[subqueries]: https://github.com/elixir-lang/ecto/pull/1231
