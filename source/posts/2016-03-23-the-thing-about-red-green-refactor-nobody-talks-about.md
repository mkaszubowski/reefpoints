---
layout: post
title: "The things about Red, Green, Refactor that nobody ever talks about"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: engineering, best practices, opinion
---

![](http://i.imgur.com/acmyARH.png)

"Red", "Green", "Refactor"

*Red*, *Green*, *Refactor*

**RED** **GREEN** **REFACTOR**

This process has been drilled into our head for over ten years. The goal
is to push to to writing better software by ensuring that only what you
have spec'd out is implemented. The problem however is when you're in
new territory. In order to write proper tests you need to have an
understanding of the system it is spec'ing. If the implementation of
that system is still a mystery then you can find yourself getting
blocked trying to dream up how to test a system you have no idea is
going to work.

Does this sound familiar?

The dogmatic approach of Red, Green, Refactor can sometimes be a
blocker. If it is preventing you from delivering business value what
good is it doing?

Well, I've got some secrets to share about Red, Green, Refactor...

### Its OK to spike the implementation first

When trying to implement something new writing the actual implementation
is sometimes easier than reasoning about how to test said system. In
these cases it is perfectly reasonable to:

1. Code spike the implementation
2. Gain knowledge on what the boundaries and requirements of the implementation are
3. Toss out the spiked code
4. Write the tests
5. Write the new implementation

More often than not you'll find this strategy to be very effective and
you'll break through the wall faster than attempting to dream up the
implementation in your head before writing the tests. You may also find
that when you get to Step 5 the re-implemented code is much better than
the spike you originally wrote.

### You don't have to follow any "order"

Take a look at the graph at the top of the page. Where does it start?
Where does it end? Most people, because of the phrase "Red, Gree,
Refactor" feel they *must* start with "Red". Well, you don't. Let's
assume you inherit an application that has poor, or no, test coverage.
It's perfectly OK to write simple acceptance tests that assert the
current behavior of the application. Go directly to "Green". This is OK
because the application is already live, its working. Once you have the
happy paths covered in the acceptance tests you've written you can
refactor with confidence.

### Break the "rules"

Like most rules "Red", "Green", "Refactor" makes sense for most cases, but
not all. In situations where you find yourself restricted or not moving forward
feel free to break the rules until you can get back to a place where
observing them again makes sense.
