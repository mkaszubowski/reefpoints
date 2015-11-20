---
layout: post
title: "Phoenix is not Rails"
social: true
author: Chris McCord
twitter: "chris_mccord"
github: chrismccord
summary: "Phoenix is not Rails, but some ideas are borrowed"
published: true
tags: phoenix, rails, elixir, ruby
---

In his yearly recap last December, Brian went public with his [plans to transition the company over to Elixir and Phoenix development](https://dockyard.com/blog/2014/12/28/lessons-learned-three-years-running-a-software-consultancy). Throughout this year, he found it was a smooth transition for the team [going from primarily Rails to Phoenix powered applications](https://dockyard.com/blog/2015/10/29/how-long-it-took-our-team-to-move-from-rails-to-phoenix).
On the surface, Phoenix shares some familiar conventions with Rails that lets folks jump into new applications and contribute early to a project – on their way to greater mastery. Complete mastery will take a bit more practice than knowing a few shared conventions, but the similar-at-a-glance features has enticed Ruby teams to get involved and many are delighted to get up and running quickly. Unfortunately, it has also led to wrong assumptions about Phoenix's likeness to Rails, causing some to miss the important differences around their core philosophies.

It is common in the Ruby community to say that there are Rails developers and Ruby developers. We don't expect this to happen with Phoenix. Although Phoenix of course introduces its own abstractions, ultimately writing a Phoenix application is writing an Elixir application. Testing Phoenix code is testing Elixir functions. This post aims to address these ideas by comparing the similarities and differences between Phoenix and Rails and why it matters.

## Similarities

Most of the phoenix-core team comes from a Rails-heavy background, so it's natural we borrow some of the great ideas Rails brings to the table, such as:

- Both focus on productivity, from client to server side
- Both provide a default directory structure, although Phoenix simply relies on the structure imposed by Elixir applications
- Both are MVC frameworks (Phoenix does a functional twist on the architecture though) with a router sitting on top
- Both provide a default stack with relational databases (sqlite3 for Rails, PostgreSQL for Phoenix)
- Both promote security best practices in their default stack
- Both ship with a default toolkit for writing and running tests


## Differences

With a few similarities, comes major differences. From how you structure your applications, recover from failure, debug your systems, or talk to a remote client, Phoenix takes an approach that few run-times can offer. We embrace Elixir and OTP conventions in Phoenix so that your Phoenix application is only a component of your greater application infrastructure. This deviation from Rails has effects throughout the stack.



### Applications

There is no such thing as a "Phoenix application". Your Phoenix projects are first and foremost Elixir applications, which relies on Phoenix to provide part of its functionality. This means there is one way to build, run, and deploy your applications – the Elixir way.

#### Why it matters: no singletons

In Rails there is a single application that's accessible via `Rails.application`. Rails runs the show, from starting the application, configuration, and even running command line tasks. As an inherent limitation of this approach, you cannot run two Rails applications side by side. If you need sharing, you need to carefully break it apart into engines and learn a new set of rules.

With Phoenix, nothing is global. There is no monolith. A new Phoenix application will include one Endpoint, one Router, and one PubSub Server, but you are free to add more. With no global state or global servers, you can break your application into pieces as your infrastructure grows.

#### Why it matters: startup and shutdown

Elixir conventions structure your projects as small composable "applications" that can be started and stopped as a unit. The trail usually goes like this (using Phoenix itself as an example):

1. Every application has a specification, that may specify which module to invoke when the application will be initialized:

  ```elixir
  def application do
    [mod: {Phoenix, []},
     applications: [:plug, :poison, :logger, :eex],
    ...]
  end
  ```
[source](https://github.com/phoenixframework/phoenix/blob/9f9c4663b304a3ff885cc8356cad278e100eb499/mix.exs#L28-L38)

2. If a module is specified, the `start/2` function of this module is invoked:

  ```elixir
  defmodule Phoenix do
    def start(_type, _args) do
      ...
      Phoenix.Supervisor.start_link
    end
  end
  ```
  [source](https://github.com/phoenixframework/phoenix/blob/7692aef141f6eab5ad9a0e88875f42c8b02b117d/lib/phoenix.ex#L3  0)

3. The `start/2` function must return the identifier of a supervised process, such as ` Phoenix.Supervisor.start_link` above

  [source](https://github.com/phoenixframework/phoenix/blob/7692aef141f6eab5ad9a0e88875f42c8b02b117d/lib/phoenix.ex#L41)

A similar flow happens when stopping your application. The consequence is that it doesn't matter if you are using Phoenix or not, every application has its own and contained start/stop mechanism.

This is a stark contrast to Rails initialization which is extremely complex and requires extensions to hijack a single, sequential initialization flow. For a Rails 4.2.2 app:

```irb
$ rails c
Loading development environment (Rails 4.2.2)
irb(main):001:0> Rails.application.initializers.length
=> 74
```

Those are 74 snippets of code (Ruby blocks) spread around multiple files in a non-specified order! Having control of the initialization logic is extremely important to know exactly what your app is running and to keep boot times fast.

#### Why it matters: monitoring and introspection

By relying on applications, you gain supervision, fault tolerance, and introspection into your running system. We can easily view our applications running as a unit, or as a whole with tools like observer:

![Imgur](http://i.imgur.com/SehijaI.png)

The beauty is, your project will start as a single application and it may (or may not) be broken into multiple applications naturally, be they all running in a single node or in a service oriented architecture. We pay no upfront cost because the runtime is built on tried and true patterns. In fact, we will cover such an example in an upcoming chapter of the [Programming Phoenix book](https://pragprog.com/book/phoenix/programming-phoenix).



### Request life-cycle

Phoenix provides fantastic performance out of the box, [with benchmarks](https://gist.github.com/omnibs/e5e72b31e6bd25caf39a) to prove it. The request/response life-cycle in Phoenix differs greatly from the approach Rails takes with Rack.

#### Why it matters: easy to understand

Explicit > Implicit. Almost Always. Phoenix favors explicitness in most of its stack. For example, when generating your Phoenix application, you can see all the "plugs" your request goes through in `lib/my_app/endpoint.ex`. Where Rails segregates Rack middleware to a side-loaded part of the application, Phoenix makes all plugs explicit. You have an instant, at-a-glance look into your request life-cycle by viewing the plugs in your endpoint and router.

```elixir
defmodule MyApp.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app

  socket "/socket", MyApp.UserSocket
  plug Plug.Static, at: "/", from: :my_app, gzip: false, only: ~w(css images js)
  plug Plug.RequestId
  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json], pass: ["*/*"]
  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, store: :cookie
  plug MyApp.Router
end
```

A request starts in your Endpoint, flows through the explicit plug "base middleware", and is handed off to your Router, which itself as just a plug. Then the router applies its own plugs before handing off to a controller, which is (you guessed it!), a Plug. A single level of abstraction throughout the entire stack makes reasoning about your request life-cycle as clear as possible. It also allows easy third-party package integration because of the simplicity of the Plug contract.

Let's compare two very similar looking controllers to see how Phoenix's functional approach with Plug makes the code easier to understand:

controller.rb:

```ruby
before_action :find_user

def show do
  @post = @user.posts.find(params[:id])
end

def find_user
  @user = User.find(params[:user_id])
end
```

controller.ex:

```elixir
plug :find_user

def show(conn, %{"id" => id}) do
  post = conn.assigns.user |> assoc(:posts) |> Repo.get(id)
  render conn, "show.html", post: post
end

defp find_user(conn, _) do
  assign(conn, :user, Repo.get(User, conn.params["user_id"]))
end
```

Unless you're a seasoned Rails developer, you wouldn't know that `show` calls `render "show.html"` implicitly. Even if it was called explicitly, you would have to know that all instance variables are copied from the controller instance to the view instance, which is a layer of complexity that few realize when first getting into Rails development. Convention over configuration is a Good Thing, but there's a threshold where implicit behavior sacrifices clarity. Phoenix optimizes for clarity, in a way that we think strikes a perfect balance with easy to use APIs. Beyond that, as an Object Oriented programmer you must be aware of all the implicit state of the instance, such as the `params` hash, the `request` object, and any instance variables set in `before_action` filters. In Phoenix, everything is explicit. The `conn` is our bag of data and line of communication with the webserver. We pass it along through a pipeline of functions called plugs, transforming the connection, and sending response(s) as needed.

#### Why it matters: easy to test

Functional programming and the Plug contract make testing your controllers in isolation, or integration testing your entire endpoint, only a matter of passing a `conn` through the plug pipeline and asserting against the result. Additionally, controller actions in Phoenix are just functions, without implicit state. If we need to test the controller in isolation, we call the function!

```elixir
test "sends 404 when user is not found" do
  conn = MyController.show(conn(), %{"id" => "not-found"})
  assert conn.status == 404
end
```

There's no stumbling with setting up controller instances thanks to functional programming. And when we need to fully integration test through the endpoint, Phoenix just calls the pipeline of functions:

```elixir
test "shows users" do
  conn = get conn(), "/users/123"
  assert %{id: "123"} = json_response(conn, :ok)
end
```

Phoenix views follow the same principle as controllers: they are all just functions, there is no implicit data sneaking in!

#### Why it matters: easy to share code

Once you end-up relying on controller instance variables and methods, a method that you wrote to run in a Rails controller cannot be easily moved to a Rack middleware because it relies on many controller internals.

Since plugs are just functions, you know what is coming in and you know what is going out. There is one abstraction for the entire HTTP stack: whether in the endpoint, router or controller. For example, let's say you want to apply an `AdminAuthentication` plug to all `"/admin"` requests, as well as a special `DashboardController`. We use the same plug at both the Router and Controller levels of abstraction:

```elixir
defmodule MyApp.Router do
  pipeline :browser do
    plug :fetch_session
    ...
    plug :protect_from_forgery
  end

  pipeline :admin do
    plug AdminAuthentication
  end
  
  scope "/" do
    get "/dashboard", DashboardController
  end

  scope "/admin" do
    pipe_through [:browser, :admin] # plugged for all routes in this scope

    resources "/orders", OrderController
  end
end

defmodule MyApp.DashboardController do
  plug AdminAuthentication # plugged only on this controller

  def show(conn, _params) do
    render conn, "show.html"
  end
end
```

Since we use `plug` at all levels of the stack, we can plug in the `AdminAuthentication` plug in the Router and controller for fine-grained request rules. In Rails, you would inherit from an `AdminController`, but the clarity of what transformations apply to your request is lost. You have to track down the inheritance tree to find out which rules are applied and where. In Phoenix, router pipelines make the concerns of your request explicit.

### Channels

Phoenix from day one was built to take on the challenges of the modern, highly connected, real-time web. Channels bring transport agnostic real-time connections to your application, which can scale to [millions of clients on a single server](http://www.phoenixframework.org/blog/the-road-to-2-million-websocket-connections). This deviates from Rails where historically real-time features have been second-class.

![Imgur](http://i.imgur.com/7CHc1Lh.png)

#### Why it matters: the web is evolving

Phoenix Channels target the Web beyond the browser. The web is evolving to include *connected devices* (phones, watches, smart toasters) – one of which is a browser. We need a framework that can evolve with changing and new protocols alike. That's why Channels are transport agnostic, with native channel clients available on iOS, Android, and Windows platforms. You can see this in action with a [Phoenix chat app running natively on a browser, iPhone, and Apple Watch](https://vimeo.com/136679715).

#### Why it matters: fast performance, with less dependencies

Rails' recent entry into real-time features with [Action Cable bring a heavy list of dependencies: Faye, Celluloid, EventMachine, Redis, to name a few](https://github.com/rails/actioncable/blob/master/actioncable.gemspec#L17-L25). Because Phoenix runs on the Erlang Virtual Machine, Phoenix gets real-time features out of the box from the run-time. The run-time is distributed, allowing Phoenix to skip any operational dependency like Redis to orchestrate PubSub messages across servers.


### Naming

Phoenix does not impose strict naming conventions, like we see in Rails.

#### Why it matters: easy to learn

Phoenix does not tie module names to the filename. Rails requires a `UsersController` to be located in a file named `users_controller.rb`. We agree conventions like these are good, but Phoenix does not care about such tight restrictions. Instead we promote sane defaults, but are flexible to individual requirements. Naming also creates a lot of confusion for people who learn Rails first then try to write Ruby applications. Because Rails depends on `const_missing` to require files based upon the class name convention of file path, knowing how to require files in a regular Ruby application is a bit of a mystery for programmers looking to move their knowledge outside of Rails.

Phoenix includes a "web" directory where you put controllers, views, etc, but it only exists for code reloading purposes which gives you refresh-driven-development.

Phoenix also does not impose singular and plural naming rules. Rails naming rules can confuse beginners and advanced developers alike: models use singular names, controllers use plural ones, URL helpers mix both, and so on. Phoenix consistently uses singular rules, as any other Elixir code. You may use plural names for your tables and router paths, but those are explicitly written at your system boundaries.


### Assets

Phoenix uses a tool named [brunch](http://brunch.io) by default for handling static assets, but it allows you to bring your own JavaScript build tool, instead of building one specific to the framework, like Rails does with the asset pipeline. Phoenix also leverages its channel layer to provide live-reload of changes out of the box.

#### Why it matters: ES6/ES2015 is the future

Phoenix promotes ES6/ES2015 instead of CoffeeScript, by supporting ES2015 out of the box for new projects. CoffeeScript served its noble purpose to push the industry forward. ES2015 and its [first-class transpilers](https://babeljs.io) are the clear way forward.

#### Why it matters: live-reload is an essential feature

Phoenix ships with live reload out of the box. As soon as you change a .js or .css file, it is automatically reloaded in your browser. Once you add this feature to your development work-flow, it's one you can't live without.


## Wrap-up

Regardless of your background, you'll find Phoenix borrows from great ideas that came before it, while using Elixir to carve its own path to take on the modern web.
