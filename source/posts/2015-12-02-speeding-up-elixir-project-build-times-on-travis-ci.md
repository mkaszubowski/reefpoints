---
layout: post
title: "Speeding up Elixir project build times on Travis CI"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: elixir, continuous integration, travis ci
---

Elixir is fast, very fast. So fast that a good chunk of [Continuous
Integration][ci] jobs on [Travis CI][travis] for our Phoenix projects were spent in
fetching dependencies (this is very small, but still a few seconds) and
then compiling all of the dependencies.

If you're willing to deal with getting a failed build once in a while
then you can significantly speed up the CI jobs by caching certain
assets. Specifically the `_build/` and `deps/` directories.

This strategy can be used on any CI service but the example here is for
Travis CI. Simply add the following to your `.travis.yml` file:

```yml
cache:
  directories:
    - _build
    - deps
```

We saw a big reduction in total Pull Request CI test run time
![total-jobs][total-jobs]

Here is a comparison of the individual jobs

Before:

![before][before]

After:

![after][after]

If you are getting a failing build when you believe you shouldn't, the
issue could be the cache. You can simply [clear the cache and start it
from scratch at any time][clear-cache].

[total-jobs]: http://i.imgur.com/jst9V2C.png
[before]: http://i.imgur.com/efm7IPa.png
[after]: http://i.imgur.com/LfXAuSk.png
[clear-cache]: https://docs.travis-ci.com/user/caching/#Clearing-Caches
[ci]: https://en.wikipedia.org/wiki/Continuous_integration
[travis]: http://travis-ci.org
