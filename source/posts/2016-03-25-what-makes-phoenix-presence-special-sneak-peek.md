---
layout: post
title: "What makes Phoenix Presence special, and a sneak peek"
social: true
author: Chris McCord
twitter: "chris_mccord"
github: chrismccord
summary: "Phoenix Presence brings cutting edge features unmatched by other frameworks. Find out how with a sneak peek."
published: true
tags: phoenix, elixir, presence
---

At DockYard, our goal is to build the fastest and most robust
applications for our clients both on the front-end and back-end. When
it comes to the server, Elixir and Phoenix give us the fastest
platform with the highest productivity. And it just keeps getting
better. New features like the much anticipated Phoenix Presence have
us extremely excited about treading new ground on what a Web framework
can accomplish.

Here's a sneak peek of the new features in action that show how we're
putting cutting edge CS research into practice and how you can try it out for yourself.
Jump below for full details:

<iframe width="420" height="315" src="https://www.youtube.com/embed/9dALrnCOLNE" frameborder="0" allowfullscreen></iframe>


### Phoenix Presence

Phoenix Presence is an upcoming feature in Phoenix 1.2 which brings
support for registering process information on a topic and replicating
this information transparently across a cluster. Its simplest use-case
would be showing which users are currently online in an application,
but we're excited about other lower-level uses such as service
discovery. This feature at first seems simple and mundane, but most
libraries fail to properly tackle it and those that do introduce extra
dependencies without solving edge-cases. Not so with Phoenix.

### What makes it special?

What's special about Phoenix's implementation is we have a system that
applies cutting edge CS research to tackle day-to-day problems in the
applications we all write. Phoenix Presence:

- has no single point of failure
- has no single source of truth
- relies entirely on the standard library with no operational
dependencies
- self heals

Unlike most libraries and web frameworks in various languages, Phoenix
does not require a central datastore to hold presence information.
While having to deploy Redis or similar datastores increases your
operational overhead, it also introduces a couple severe penalties – a
single point of failure, and central bottleneck. Worse still, if one
of your servers goes down, you'll have orphaned data stuck permanently
in your database. With Phoenix, we've developed a system based on a
distributed heartbeat/gossip protocol which uses a
[CRDT](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type)
to replicate data in a conflict-free way. This gives you high
availability and performance because we don't have to send all data
through a central server. It also gives you resilience to failure
because the system *automatically recovers from failures*. This
includes other nodes going up or down or spotty networks causing
netsplits and missed data replication.

### Great platforms yield great solutions

None of this would be possible without the innovations from Elixir and
Erlang which gives us a distributed runtime that's unmatched by other
languages. When we sat down to design Phoenix Presence, instead of
immediately asking "which database would be best to hold presences?",
we could ask "how can we best replicate data in a distributed system
without the user having to worry about it?". The platforms you build
on top of drive the design decisions you make in your products. With
Elixir, you are empowered to tackle problems that in other platforms
would feel impossible to solve without tradeoffs with heavy dependencies.
Overtime these decisions play out to more reliable products and services, 
and better user experiences.
