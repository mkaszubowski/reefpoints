---
layout: post
title: "Code Linting: An Inside Look"
author: "Estelle DeBlois"
twitter: "edeblois"
github: "brzpegasus"
published: true
tags: ember, javascript
---

A little while back, I wrote a [blog post][suave-up-your-code] introducing [`ember-suave`][ember-suave], an addon that we created at DockYard to help enforce a common code style across all of our projects. With the addon installed, any code that doesn't align with the established styleguide will cause the build to fail. During development, as files are modified, the linter will reprocess the changed files, displaying errors in the console right away.

If you've adopted `ember-suave` in your own projects, you may be content to find that things just work. But there's a lot of satisfaction to be had with understanding how the addon does what it does.

Let's start at the core with JSCS.

## JSCS

[JSCS][jscs] is the wonderful library that uses a set of predefined code style rules to lint your code. It comes with a very simple API:

```js
let Checker = require('jscs');
let checker = new Checker();

checker.registerDefaultRules();

checker.configure({
  verbose: true, // shows rule name next to error messages
  requireSpaceBeforeBinaryOperators: true,
  requireSpaceAfterBinaryOperators: true
});
```

As this snippet shows, once you install [`jscs`][node-jscs] from NPM and create a new `Checker` instance, all you need to do is register the default JSCS rules and configure which ones to enable. You can now start linting your code:

```js
let results = checker.checkString('let x = y+z;');
let errors = results.getErrorList().map((error) => {
  return results.explainError(error);
});
console.log(errors.join('\n'));
```

Running this example will output the following:

```
requireSpaceBeforeBinaryOperators: Operator + should not stick to preceding expression at input :
     1 |let x = y+z;
-----------------^
requireSpaceAfterBinaryOperators: Operator + should not stick to following expression at input :
     1 |let x = y+z;
------------------^
```

It's as simple as that! Of course, this example is merely checking a String literal. In practice, you would want to check the content of your application files, one at a time. This is where [broccoli-jscs][broccoli-jscs] comes in.

## broccoli-jscs

`broccoli-jscs` was created by [Kelly Selden][kellyselden], and encompasses both a Broccoli plugin and an Ember CLI addon.

As a [plugin][broccoli-plugin], `broccoli-jscs` implements a `JSCSFilter` function that accepts a collection of input nodes, which map to file paths. Each file is read into a string, which is then passed to JSCS's `checkString` method for linting. Every time that you make a change to a file while `ember s` is running, the file will be reprocessed by the plugin, and any JSCS errors found will be displayed in the console.

In addition, `JSCSFilter` will generate a test file for every file represented in the input nodes. Given `foo/example.js`, the plugin will output a test file named `foo/example.jscs-test.js`, with the following content:

```js
module('JSCS - foo');
test('foo/example.js should pass jscs', function() {
  ok(false, 'foo/example.js should pass jscs.\nrequireSpaceBeforeBinaryOperators: Operator + should not stick to preceding expression at foo/example.js :\n     1 |let x = y+z;\n-----------------^\n     2 |\nrequireSpaceAfterBinaryOperators: Operator + should not stick to following expression at foo/example.js :\n     1 |let x = y+z;\n------------------^\n     2 |');
});
```

If no JSCS errors are found, the test file is still generated, but with a passing assertion: `ok(true, /* message */)`.

As an addon, `broccoli-jscs` implements the `lintTree` function, which is one of the many hooks that Ember CLI exposes, as a way to extend the core build pipeline. In this case, the function simply creates a new instance of the `JSCSFilter` plugin and returns it. Ember CLI will call the hook for every addon discovered inside a project, if it is defined. So if you install `broccoli-jscs` as an addon, its `lintTree` function will be called on every build or re-build, therefore linting your code every time it changes.

It is worth mentioning that the `JSCSFilter` plugin instance returned by `lintTree` is also considered a node (representing the collection of JSCS test files), and this node further serves as an input node to additional plugins along the course of building out the project. For instance, it is passed to `broccoli-babel-transpile` to turn ES2015 code into ES5 syntax, then to `broccoli-concat` in order to be concatenated with other files and produce a single `assets/tests.js` file.

## So where does `ember-suave` fit in this picture?

If you install `ember-suave`, the Ember CLI addon portion of `broccoli-jscs` isn't used. The goal of `ember-suave` is to augment the plugin provided by `broccoli-jscs`, by configuring it with a set of rules (both JSCS built-in rules as well as custom ones defined inside of `ember-suave`), so you don't have to do so for each project. As such, it has its own `lintTree` implementation that calls out to the `JSCSPlugin`.

## Eager for more?

Even though this post focuses on `ember-suave`, you can imagine the process being very similar for other linters, such as JSHint or ESLint.

Understanding the inner workings of a build helps tremendously for various situations: when something breaks, you know where and what to look for. Furthermore, you are now better equipped to build extensions of your own, should the need arise.

If you found this post informative, and would love to learn more about Ember CLI's build process, available hooks, and how to use them, [EmberConf][ember-conf] is right around the corner. I'll be diving more into this topic as part of my talk on "Dissecting an Ember CLI Build".

[suave-up-your-code]: https://dockyard.com/blog/2015/08/07/suave-up-your-code
[ember-suave]: https://github.com/DockYard/ember-suave
[jscs]: http://jscs.info/
[node-jscs]: https://www.npmjs.com/package/jscs
[broccoli-jscs]: https://github.com/kellyselden/broccoli-jscs
[kellyselden]: https://github.com/kellyselden
[broccoli-plugin]: https://github.com/broccolijs/broccoli-plugin
[ember-conf]: http://emberconf.com/
