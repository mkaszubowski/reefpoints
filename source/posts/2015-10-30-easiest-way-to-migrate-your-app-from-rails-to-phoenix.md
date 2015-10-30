---
layout: post
title: "Easiest Way To Migrate Your App From Rails to Phoenix"
comments: true
author: Brian Cardarella
twitter: bcardarella
github: bcardarella
social: true
published: true
tags: elixir, phoenix, rails, ruby
---

So after you've [ramped your team up on how to write Phoenix
apps][convert] you now have your eyes set on transitioning your existing
application from [Rails][rails] to [Phoenix][phoenix]. You go to your boss, make the
proposal, and it goes something like this: 

![batman][batman]

The [Big Rewrite][big-rewrite] is never a popular topic. So let's not do
that. Instead I'm suggesting moving one action over at a time, from
Rails to Phoenix. Running both apps in parallel. Let's take a look at
how this could work.

### Handling simple actions

![Request Response Cycle for a typical Rails app][rails-cycle]

Let's put aside for a moment the particular unique complexities of
**your** app and just focus on the common pattern:

1. Requests come in
1. Rails handles them
1. Responses go out

You've identitifed a specific action in your Rails app that is a bit of
a dog. Let's assume for the moment that it is a good candidate for
Phoenix, maybe its a data serialization action for an API. You spike out
a similar action in a new Phoenix app and run a benchmark comparison:

![Pizza over Cats][pizza-cats]

What we want to do is have Phoenix act as a proxy server. Any requests
it cannot handle it will delgate to the Rails application:

![Request Response Cycle with Phoenix acting as a proxy][phoenix-cycle]

We're going to simply write a [Plug][plug] to handle this.

In `web/router.ex` let's wrap all of our routes in a new `:rails_proxy`
pipeline:

```elixir
pipeline :rails_proxy do
  plug :fallback_proxy, Application.get_env(:rails, :url)
end

scope "/", MyApp do
  pipe_through :rails

  # routes go here
end
```

That's it! Now Phoenix will handle the routes that it knows about.
Anything that doesn't match will be delegated to the Rails application.
This of course means that `404`s will be rendered by Rails and not
Phoenix. You can continue migrating over actions one at a time, while
continuing to deploy to production.

### Handling authenticated routes

What about actions that require session management? (i.e.
authentication)

Phoenix has got you covered! Check out the great package
[plug\_rails\_cookie\_session\_store][plug-rails]. This package will
allow your Phoenix application to read/write to the Rails session in the
cookie. If you are storing `user_id` in the Rails session for actions
that require authorization you can do the same in Phoenix.

### Allowing Phoenix to Supervise your Rails app

One of the benefits of Elixir is the fault-tolerance it inherits from
Erlang with [Supervisors][supervisor]. What is really nice is that we
can have Phoenix run and supervise our Rails application. Imagine only
having to handle the deployment for your Phoenix application. Pheonix
will treat Rails as a simple worker process and shut it down and bring
it back up when necessary. The Supervisor will monitor the Rails
process, if it dies Elixir automatically brings it back up! Now you've
also replaced whatever uptime monitor you were using to handle this.



[supervisor]: http://elixir-lang.org/docs/v1.0/elixir/Supervisor.html
[plug-rails]: https://github.com/cconstantin/plug_rails_cookie_session_store
[plug]: https://github.com/elixir-lang/plug
[phoenix-cycle]: http://i.imgur.com/RzeCg67.png
[pizza-cats]: http://i.imgur.com/xlO6Pu3.png
[rails-cycle]: http://i.imgur.com/TvOdED1.png
[batman]: http://i.imgur.com/r8TFcK4.jpg
[convert]: https://dockyard.com/blog/2015/10/29/how-long-it-took-our-team-to-move-from-rails-to-phoenix
[rails]: http://rubyonrails.org
[phoenix]: http://phoenixframework.org
[elixir]: http://elixir-lang.org
