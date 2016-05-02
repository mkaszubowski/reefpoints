---
layout: post
title: "Phoenix Tips and Tricks"
social: true
author: Chris McCord
twitter: "chris_mccord"
github: chrismccord
summary: "tips and tricks to keep your phoenix code clean and concise"
published: true
tags: elixir, phoenix
---

As newcomers get up and running quickly with Phoenix, we see folks hit a few common issues that they can cleanly solve with a few simple tips.


### Override `action/2` in your controllers

Often times, you'll find yourself repeatedly needing to access connection information in your controller actions, such as `conn.assigns.current_user` or similarly reaching deeply into nested connection information. This can become tedious and obscures the code. While we could extract the lookup to a function, such as `current_user(conn)`, then we are needlessly performing extra map access when we only need to do the lookup a single time. There's a better way.

Phoenix controllers all contain an `action/2` plug, which is called last in the controller pipeline. This plug is responsible for calling the function specified in the route, but Phoenix makes it overridable so you can customize your controller actions. For example, imagine the following controller:

```elixir
defmodule MyApp.PostController do
  use MyApp.Web, :controller

  def show(conn, %{"id" => id}) do
    {:ok, post} <- Blog.get_post_for_user(conn.assigns.current_user, id)
    render(conn, "show.html", owner: conn.assigns.current_user, post: post)
  end

  def create(conn, %{"post" => post_params}) do
    {:ok, post} <- Blog.publish_post(conn.assigns.current_user, id)
    redirect(conn, to: user_post_path(conn, conn.assigns.current_user, post)
  end
end
```

Not terrible, but the repeated `conn.assigns.current_user` access gets tiresome and obscures what we care about, namely the `current_user`. Let's override `action/2` to see how we can clean this up:

```elixir
defmodule MyApp.PostController do
  use MyApp.Web, :controller

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns[:current_user] || :guest]
    apply(__MODULE__, action_name(conn), args)
  end

  def show(conn, %{"id" => id}, current_user) do
    {:ok, post} <- Blog.get_post_for_user(current_user, id)
    render(conn, "show.html", owner: current_user, post: post)
  end

  def create(conn, %{"post" => post_params}, current_user) do
    {:ok, post} <- Blog.publish_post(current_user, id)
    redirect(conn, to: user_post_path(conn, current_user, post)
  end
end
```

Much nicer. We simply overrode `action/2` on the controller, and modified the arities of our controller actions to include a new third argument, the `current_user`, or `:guest` if we aren't enforcing authentication. If we want to apply this to multiple controllers, we can extract it to `MyApp.Controller` module:


```elixir
defmodule MyApp.Controller do
  defmacro __using__(_) do
    quote do
      def action(conn, _), do: MyApp.Controller.__action__(__MODULE__, conn)
      defoverridable action: 2
    end
  end

  def __action__(controller, conn) do
    args = [conn, conn.params, conn.assigns[:current_user] || :guest]
    apply(controller, Phoenix.Controller.action_name(conn), args)
  end
end
```

Now any controller that wants to use our modified actions can `use MyApp.Controller` on a case-by-base basis. We also made sure to make `action/2` overridable again to allow caller's downstream to customize their own behavior.


### Rendering the `ErrorView` directly

Most folks use their `ErrorView` to handle rendering exceptions after they are caught and translated to the propper status code, such as a `Ecto.NoResultsError` rendering the "404.html" template or a `Phoenix.ActionClauseError` rending the "400.html" template. What many miss is the fact that the ErrorView is just like any other view. It can and should be called directly to render responses for your error cases rather than relying on exceptions for all error possibilities. For example, imagine handling the error cases for our `PostController` in the previous example:

```elixir
def create(conn, %{"post" => post_params}, current_user) do
  with {:ok, post} <- Blog.publish_post(current_user, id) do
    redirect(conn, to: user_post_path(conn, current_user, post)
  else
    {:error, changeset} -> render(conn, "edit.html", changeset: changeset)
    {:error, :unauthorized} ->
      conn
      |> put_status(401)
      |> render(ErrorView, :"401", message: "You are not authorized to publish posts")
    {:error, :rate_limited} ->
      conn
      |> put_status(429)
      |> render(ErrorView, :"429", message: "You have exceeded the max allowed posts for today")
  end
end
```

Here we've used the Elixir 1.3 `with/else` expressions. Note how we are able to succinctly send the 401 and 429 responses by directly rendering our `ErrorView`. We also passed the template name as an atom, such as `:"401"` so our template will be rendered based on the accept headers such as `"401.json"` or `"404.html"`.


### Avoid Task.async if you don't plan to Task.await

Elixir Tasks are great for cheap concurrency and parallelizing bits of work, but we often see `Task.async` used incorrectly. The most important thing to realize is that the caller is linked to the task. This means that if the task crashes, the caller does as well, and vice-versa. For example, the following code is perfectly fine because we await both tasks and we expect to crash if they fail:

```elixir
def create(conn, %{"access_code" => code}) do
  facebook = Task.async(fn -> Facebook.get_token(code) end)
  twitter  = Task.async(fn -> Twitter.get_token(code) end)

  render(conn, "create.json", facebook: Task.await(facebook),
                              twitter: Task.await(twitter)
end
```

In this case, we want to fetch a token from Facebook and Twitter, and we can do this work in parallel since the tasks do not coupled in any way. When rendering our JSON response for the client, we can await both tasks and send the response back. This use of `Task.async` and `Task.await` is just fine, but now imagine another case where we want to fire off a quick task and immediately respond to the client.

```elixir
def delete(conn, _, current_user) do
  {:ok, user} = Accounts.cancel_account(current_user)
  Task.async(fn -> Audits.alert_cancellation_notice(user) end)

  conn
  |> signout()
  |> put_flash(:info, "So sorry to see you go!")
  |> redirect(to: "/")
end
```

In this case, we want to notify our staff about an account cancellation, say by sending an email, but we don't want the client to wait on this particular work. It might feel natural to use `Task.async` here, but since we aren't awaiting the result and the client isn't concerned about its success, we have an issue. First, we are linked to the caller, so any abnormal exit on either side will crash the other. The client could get a 500 error after their account has been canceled and not be sure if their operation was successful. Likewise, our staff notice could be brought down by an error when sending the response, preventing our staff notice of the completed event. We can use `Task.Supervisor` and its `async_no_link` to achieve an offloaded process that is isolated under its own supervision tree.

First, we'd need to add our own `Task.Supervisor`, to our supervision tree, in `lib/my_app.ex`:

```elixir
children = [
  ...,
  supervisor(Task.Supervisor, [[name: MyApp.TaskSupervisor]])
]
```

Next, we can now offload the task to our supervisor. We'll also use the `async_no_link` function to isolate the task from the caller:

```elixir
def delete(conn, _, current_user) do
  {:ok, user} = Accounts.cancel_account(current_user)
  Task.Supervisor.async_no_link(MyApp.TaskSupervisor, fn ->
    Audits.alert_cancellation_notice(user) end)
  end)

  conn
  |> signout()
  |> put_flash(:info, "So sorry to see you go!")
  |> redirect(to: "/")
end
```

Now our task is properly offloaded to its own supervisor who will take care of any failures and proper logging. Likewise, any crash in the task, or the controller, won't affect the other.


With these tips, you'll keep your code clean and to the point, and isolated when required.
