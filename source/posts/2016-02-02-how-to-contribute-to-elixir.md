---
layout: post
title: "How to contribute to Elixir"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: elixir
---
I just got my [first commit accepted into the Elixir programming
language][first-commit]. Here are some notes on how to build and test [Elixir][elixir-website] on your
machine to help you make your own contributions.

### Up and running

After you've [cloned Elixir][elixir-github] you'll need to ensure that the state of your
copy builds properly and all the tests pass. To do this you'll need to
use [Make][make]. Simply run the following:

```console
$ make compile
$ make test
```

Hopefully the purpose of each command should be obvious. The entire test suite for
the language doesn't take too long to complete. Once all the tests pass
you can start. In the event that any of the two steps fail I would
recommend getting help in the `#elixir-lang` IRC channel on Freenode.

### You've made your changes

Assuming you've made your changes you'll need to test them. For any
changes that you've made to the language you'll need to recompile. You
can re-run the commands from above in the root directory of the project.

Elixir itself is made up of several packages. They're all listed in the
`lib/` directory:

```
lib
├── eex
├── elixir
├── ex_unit
├── iex
├── logger
└── mix
```

Depending upon the package you are making changes to you may not want to
run the entire test suite. For example, to compile and run the tests for
`ex_unit` only you can run:

```console
$ make test_ex_unit
```

[Check out the `Makefile` in Elixir for the available commands for testing 
individual packages][make-test-commands].

Even this can be tedious. If you really want to move fast you can target
a specific test file to run. Let's say you want to target the test file
for `ExUnit.Case`:

```console
$ make compile
$ bin/elixir -r lib/ex_unit/test/test_helper.exs lib/ex_unit/test/ex_unit/case_test.exs
```

The second command will use the custom build of Elixir that is the
result from `make compile`. The option `-r` will run the specific
file at that path.

This should get you into a faster feed-back loop to ensure that your
tests for the changes you've made are passing.

### Real-world testing

It could be that you are making a commit to scratch an itch in an app
you're building. In that event it would be great to ensure that the
changes you're making in the language actually work for you. We can
easily test this by using the custom build of Elxiir with your
application.

In a Linux-based shell you can prepend the `bin/` path of the custom
Elixir build onto `$PATH` so it takes precedence:

```console
$ export PATH=/home/yourname/elixir/bin:$PATH
```

Replace `/home/yourname/elixir/bin` with whatever the path is for your
machine. If you really want to live on the edge you can add this to your
[Bash][bash] or [Zsh][zsh] config, but I wouldn't recommend it.

You should confirm that your custom build is the one found. You can do
this by running: `which elixir` and `which mix`. If it doesn't return
the path for the custom build you should revisit the steps above and see
why not.

You will likely need to recompile the dependencies for the custom build
of Elixir:

```console
$ mix do deps.clean, deps.get, deps.install
```

Assume your application is using the changes you've made just run `mix
test` as normal to confirm that your changes work.

### Documentation

You may have to document your changes. [Please see the Elixir guide on
writing good documentation][doc-guide].

### Bad builds

Sometimes there may be a bad build during compilation. In this event you
can just run:

```console
$ make clean
```

This will reset the project to a clean state. You can now try to
re-compile.

### Finish up

I think you'll be surprised how easy and straight forward it is to
contribute back to Elixir. Hopefully these tips have made it a bit
smoother for you.

[first-commit]: https://github.com/elixir-lang/elixir/pull/4233
[elixir-website]: http://elixir-lang.org
[elixir-github]: https://github.com/elixir-lang/elixir
[make]: https://en.wikipedia.org/wiki/Make_(software)
[bash]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
[zsh]: http://www.zsh.org/
[doc-guide]: http://elixir-lang.org/docs/master/elixir/writing-documentation.html
[make-test-commands]: https://github.com/elixir-lang/elixir/blob/d9748b4e3139fbac98119aa8ee697af06c40b0ec/Makefile#L206
