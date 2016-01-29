---
layout: post
title: "Heroic Elixir Pipelines"
comments: true
social: true
author: Aaron Sikes
twitter: "courajs"
github: courajs
summary: "The pipe operator has a huge effect on Elixir for how simple
it is. Learn how to use its power in your own functions"
published: true
tags: elixir, best practices
---

One small source of beauty in Elixir code is the [pipe operator][pipe]. It passes the expression on the left as the first argument to the function on the right:

```elixir
1..100_000
|> Enum.map(&(&1 * 3))
|> Enum.filter(odd?)
|> Enum.sum
```

Here, a range of numbers is being passed through a chain of several operations. Much of the Elixir standard library can be used like this.

Code like this is great to read. It’s got a protagonist. Our hero navigates trials, and comes out changed on the other side. Humans are wired to understand a story.

But do you ever think about how to keep your own functions pipeable? Here’s a hypothetical bit of Elixir code: 

```elixir
def read_time(str) do
  str
  |> String.split(" ")
  |> Enum.count
  |> Kernel./(200)
  |> Integer.to_string
  |> Kernel.<>("minutes")
end

def related_posts(title, body) do
  related_posts_by_title(title) ++ related_posts_by_body_text(body)
end

...

def publish_post(%Post{body: body, title: title} = post) do
  word_count = read_time(body)
  related_posts = related_posts(title, body)
  App.publish(%{post | word_count: word_count, related_posts: related_posts})
end
```

Here, the wonderful piping action is present in the `read_time` function, where you’re sticking to the standard library. But where did it go in the `publish_post` method? The functions you're writing aren't built to facilitate piping. A good pipeable function takes some thought.

Who is your hero? Here it's your `post` object. To write pipeable functions, your functions should take this hero as their first argument, and return a modified version/representation. Your first argument is your pipe intake, and your return value is your pipe outflow.

Taking your hero as your second argument (as the sidekick), or taking only specific properties, or returning another value rather than a modified version can all break pipeability. Sometimes you want to do those things for unit tests, or for encapsulation and reusability, but you can always write a wrapping function that is more pipeable. Here’s how I’d use those techniques here:

```elixir
def annotate_read_time(%Post{} = post) do
  %{post | read_time: read_time(post.body)}
end

def add_related_posts(%Post{body: body, title: title} = post) do
  %{post | related_posts: related_posts(body, title)}
end

...

def publish_post(%Post{} = post) do
  post
  |> annotate_read_time()
  |> add_related_posts()
  |> App.publish()
end
```

Ah, that’s better! We realized our hero is the humble post. It learns a few things about itself along the way, and at the end of its journey is published to the world.

So. When writing your code, discover your protagonist. Write functions which take your hero as the first argument, and return it changed for the better. Then The Hero’s Journey will be complete, and you can have beautiful pipelines running all throughout your code.

[pipe]: http://elixir-lang.org/docs/v1.0/elixir/Kernel.html#|>/2
