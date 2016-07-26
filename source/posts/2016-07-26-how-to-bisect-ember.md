---
layout: post
title: "How to use git bisect by example"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "Learn how to use Git's bisect command with Ember.js as the example"
published: true
tags: git, bisect, javascript, ember
---

I'm writing this tutorial because I ran into a problem with Ember.js the other day. The problem was that the test suite did not pass anymore on Ember.js' canary build channel, while it used to pass before. After debugging the problem I wanted to find out which commit in Ember.js did break the tests. Thanks to [Robert Jackson](https://twitter.com/rwjblue), who pointed me to a [GitHub comment](https://github.com/emberjs/ember.js/issues/13846#issuecomment-234133694), I've been able to use `git bisect` to find the commit that introduced the issue and [report](https://github.com/emberjs/ember.js/issues/13888) it.

### What bisect does

`git bisect` uses a [binary search algorithm](https://en.wikipedia.org/wiki/Binary_search_algorithm) to find the first commit that introduced the bug you are looking for. You will have to tell the bisect command one commit you are sure contains the bug and one commit that you are sure of that it does not contain the bug. Bisect will then start searching, asking you if a given commit it proposes is good or bad, until it has found the commit that introduces your bug.

### Using bisect on Ember.js

To find out what commit has introduced a bug in the [Ember.js](https://github.com/emberjs/ember.js) repository, you need to clone a different repository, that is [`components/ember`](https://github.com/components/ember), which contains the Bower builds of Ember.js. You can link this repo to your app directly and then use `git bisect` to find the first build that contains the bug. You can then cross-reference the build with the real Ember.js repo to find the actual commit that introduced the bug.

To clone and link the `component/ember` repository:

```
git clone git@github.com:components/ember.git components-ember
cd components-ember
git checkout canary
bower link
```
