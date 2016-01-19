---
layout: post
title: "Phoenix best practice: Decorating in views"
comments: true
author: Dan McClain
twitter: "\_danmcclain"
github: danmcclain
social: true
summary: "Keeping your logic where it belongs"
published: true
tags: elixir, phoenix, best practices
---

Recently I was updating an older Phoenix app that was built when I was
first familiarizing myself with Phoenix and realized there were a couple
architectural mistakes in some of the controllers and views. I rectified
those mistakes with the following patterns.

## Keep your database out of my view by preloading

The view layer in Phoenix serves as a [decorator][decorator-pattern] for
the template you are about to render. It serves to merge data retrieved
in the controller with the additional details that may be needed. On our
[JSON API][json-api] backends, we use [ja_serializer][ja_serializer] to
convert our models into the proper response. When we have additional
details (say we include a blog post's author for side loading into
Ember), we  want to make sure that we preload this data before it gets
to the view. If we preload from the view itself, we will be creating an
[N+1 scenario][nplusone].

Let's take the case of an index route where you have 20 posts you want
to render. When we wait until we get to the view's `show.json` (which
renders the individual post) to retrieve the author, we will be doing 20
additional SQL queries, as we will be getting the post one by one. If we
preload the author relationship in the controller, we will be executing
a single query that retrieves *all* the authors and places them in the
struct with the post information.

## Keep your decoration out of your controllers

You may have additional information you want your view to have access
to. In one case that I came across, we query the database to find the
number of blog posts a specific tag has. We end up storing the
information in a map in the function we created to look up that
information, where the key is the id of the tag, and the value is the
number of posts for that tag. We just went over why you don't want to do
this work in your view, so how do we pass that information down? We can
use the `Plug.Conn.assign` ([docs][assign-docs]) to store the
information on the `conn` which is passed to render in the controller.
What we don't want to do is start `Enum.map`ing across the list of tags
and munging the data in the controller. That would be *decorating* the
model, which is the job of the view.

## Everything in its right place

By following the practice of decorating in the view, and doing data
retrieval in the controller, it actually makes it quite difficult to
create an N+1 query. When you have a list of records, the easiest way to
preload data (if you aren't using `Ecto.Query.preload`), is to call
`Repo.preload(collection, keys)`, which will only perform a single query
in the end.

Moving from Rails to Phoenix, I've personally found there to be fewer
footguns to shoot myself with. I think a big part of that ends up being
the fact that with a functional language, you can't accidentally make a
call to the database because your relationship can't load itself. With
Ecto, I have to explicitly load the data for the relationships and that
requires me to think about *when* is the best point to do so.

[decorator-pattern]: https://en.wikipedia.org/wiki/Decorator_pattern
[json-api]: http://jsonapi.org/
[ja_serializer]: https://github.com/AgilionApps/ja_serializer
[nplusone]: http://stackoverflow.com/a/97253
[assign-docs]: http://hexdocs.pm/plug/Plug.Conn.html#assign/3
