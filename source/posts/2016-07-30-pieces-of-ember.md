---
layout: post
title: "Pieces of Ember"
author: "Heather Brysiewicz"
twitter: "caligoanimus"
github: "hbrysiewicz"
published: true
tags: ember, javascript
summary: "How to leverage the ember ecosystem without the ember ecosystem"
---

I've been working with Ember for years now, even though it feels like just yesterday. Not everyone has had this opportunity and I am often met with questions from inquisitive developers and engineers.

They know that Ember is an ambitious framework. They've heard it can help boost their productivity. Yet, they hesitate. The project in their hands is "basically just a landing page" or they believe any framework to be "overkill" - and this concern can be valid. Ember is a full-fledged framework with opinions and build tools and "shortcuts" that enable me, an ember developer, to focus on engineering an application rather than boilerplate and redundancy.

What they probably don't know is that many of the core pieces that make the Ember ecosystem the beautiful powerhouse it is are also available as micro-libraries.

<br><br>
<div style="text-align:center;">
  <img src="/images/2016-07-10-pieces-of-ember/ember-building-blocks.png">
</div>
<br><br>

Some of the most well known micro-libraries behind the ember framework are:

* [tildeio/rsvp.js][rsvp]
* [broccolijs/broccoli][broccoli]
* [tildeio/route-recognizer][route-recognizer]
* [tildeio/router.js][router]
* [wycats/handlebars.js][handlebars]
* [tildeio/htmlbars][htmlbars]

These pieces of ember would be able to provide any JavaScript project with:

* Promises
* Build tools
* Routing capabilities
* View templating
* Templating with Virtual DOM

All without the need to buy into the entire ember ecosystem.

### [tildeio/rsvp.js][rsvp]

This library is a tiny implementation of the [Promises/A+ spec][promises]. This can be used without a transpiler just like any other promise library.

The library itself is rather similar to [Bluebird][bluebird] and [When][when]. Under the hood there are some performance boosts gained by avoiding unnecessary internal promise allocations. This provides noticeable improvements in many common scenarios.

The other unique thing to note about this library is that RSVP aims to be fast across more than just the V8 runtime, while libraries like Bluebird are more or less V8-focussed.

```js
let RSVP = require('rsvp');

let promise = new RSVP.Promise((resolve, reject) => {
  //succeed
  resolve(value);
  // or reject
  reject(error)
});

promise.then((value) => {
  //success
}).catch((error) => {
  // failure
});

```

### [broccolijs/broccoli][broccoli]

Broccoli is the fast build pipeline used by [ember-cli][ember-cli] and that is available otuside of the ember ecosystem. Broccoli is intended to be relatively easy to learn, performant, and composable. The plugin system for broccoli is what makes it so composable and even with plugins depending on other plugins, creating a large tree of plugin dependencies, broccoli manages to still provide performat sub-second speeds.

Broccoli provides a powerful build toolchain that can be used very easily to get a project up and running outside of ember.

Given a simple project with the following structure:

```
.
+-- app
|   +-- css
|   +-- js
|   +-- img
|   +-- index.html
+-- node_modules/
+-- .gitignore
+-- Brocfile.js
+-- README.md
+-- package.json
```

It is easy to serve up the assets and create a pipeline with just a few key broccoli plugins and a rather short `Brocfile.js`.

```bash
$ npm i --save-dev broccoli-concat
$ npm i --save-dev broccoli-merge-trees
$ npm i --save-dev broccoli-static-compiler
$ npm i --save-dev broccoli-uglify-js
```

```js
'use strict';

const concatenate = require('broccoli-concat');
const mergeTrees = require('broccoli-merge-trees');
const pickFiles = require('broccoli-static-compiler');
const uglifyJS = require('broccoli-uglify-js');

const app = 'app';

let appCSS;
let appHTML;
let appJS;
let appImages;

/*
 * move index from `app/` to root of tree
 */
appHTML = pickFiles(app, {
    srcDir: '/',
    files: ['index.html'],
    destDir: '/'
});

/*
 * concat and compress all js files from `app/js/` and move to root
 */
appJS = concatenate(app, {
  inputFiles: ['js/**/*.js'],
  outputFile: '/app.js'
});

appJS = uglifyJS(appJS, {
  compress: true
});

/*
 * concat all css files from `app/css/` and move to root
 */
appCSS = concatenate(app, {
  inputFiles: ['css/**/*.css'],
  outputFile: '/app.css'
});

/*
 * move images from `app/img` to image folder
 */
appImages = pickFiles(app, {
  srcDir: '/img',
  files: ['**/*'],
  destDir: '/img'
});

// merge the trees and export
module.exports = mergeTrees([appHTML, appJS, appCSS, appImages]);

```

Now running `broccoli serve` will build and serve the project and provide build times in a well formated and easy to read table.

```
Serving on http://localhost:4200


Slowest Trees                                 | Total
----------------------------------------------+---------------------
SourceMapConcat                               | 30ms
UglifyJSFilter                                | 13ms
BroccoliMergeTrees                            | 7ms
StaticCompiler                                | 3ms

Slowest Trees (cumulative)                    | Total (avg)
----------------------------------------------+---------------------
SourceMapConcat (1)                           | 30ms
UglifyJSFilter (1)                            | 13ms
BroccoliMergeTrees (1)                        | 7ms
StaticCompiler (2)                            | 6ms (3 ms)

Built - 63 ms @ Tue Jul 26 2016 16:43:40 GMT-0700 (PDT)
```

When ready to build for deployment the command `broccoli build 'dist'` would compile all of the assets into the `dist` directory.

### [tildeio/route-recognizer.js][route-recognizer]

TL;DR The full example I'm going to review can be found at [hbrysiewicz/route-recognizer-example][route-recognizer-example].

Route-recognizer handles parsing URLs for single page apps. It ships with every build of ember and is currently undergoing a rewrite by <a href='//nathanhammond.com/'>Nathon Hammond</a> that will make it more performant. As one would expect, route-recognizer could be used in practically any JavaScript application to map URLs to different handlers.

The current version of route-recognizer uses regular expressions to match static segmants, dynamic segmants, and globs. The source for this solution is relatively straight forward. The new version of [route-recognizer][nh-route-recognizer] written by Nathan Hammond uses a nondeterministic finite automata (NFA) to handle the route mapping which ends up being extremely performant. It simplifies the entire process by using one data structure and one transition function to implement. So now, instead of loading up the app with an entire route-recognizer that serializes and deserializes routes, the app now only needs the NFA representation of the routes and a transition method.

The route-recognizer alone is pretty bare. It does one thing and does it well. There is a bit of work that needs to be done to manage the URL state, recognize a URL change, and manage the transitions between states. This is where something like a router and a URL listener would come in handy. The router would be that more comprehensive layer responsible for implementing the route-recognizer.

Let me show you how you would get it working in a project outside of Ember though, because that's the fun stuff and really what makes this post worthwhile.

For this example I'm using a build process similar to the one discussed in the broccoli section except I've added the ability to use named amd modules. The example project for the following code can be found at [hbrysiewicz/route-recognizer-example][route-recognizer-example]. This example is only going to cover the route-recognizer pieces.

```js
// router.js

import RouteRecognizer from 'route-recognizer';
import postsHandler from 'routes/posts';
import postHandler from 'routes/post';

let router = new RouteRecognizer();

router.add([{ path: "/posts", handler: postsHandler }]);
router.add([{ path: "/posts/:post_id", handler: postHandler }]);

export default router;
```

By including route-recognizer in my project I can now map specific URLs to handlers. Now if I include this router in my project and call the `recognize()` method on the router, I will get back the `handler` and any parameters captured by dynamic segments and any `queryParams`

```js
// app.js

import router from 'router';

let result = router.recognize("/posts");
console.log('Response from call to "/posts":', result);
// Response from call to "/posts": {"0":{"handler":{"name":"posts"},"params":{},"isDynamic":false},"queryParams":{},"length":1}

result = router.recognize("/posts/1");
console.log('Response from call to "/posts/1":', result);
//Response from call to "/posts/1": {"0":{"handler":{"name":"post"},"params":{"post_id":"1"},"isDynamic":true},"queryParams":{},"length":1}

result = router.recognize("/posts?sortBy=name");
console.log('Response from call to "/posts?sortBy=name":', result);
//Response from call to "/posts?sortBy=name": {"0":{"handler":{"name":"posts"},"params":{},"isDynamic":false},"queryParams":{"sortBy":"name"},"length":1}
```

It's easy to see how this could be used now in tangent with a router of your own or the one I'm about to discuss in your app.

### [tildeio/router.js][router]

TL;DR The full example I'm going to review can be found at [hbrysiewicz/router-example][router-example].

The route-recognizer alone doesn't get you the best routing experience out of the box, unfortunately. It requires that you still manage the state of the URL and the transitions. However, the ember router itself is also available outside of the ember ecosystem. This will take us from the above example to actual routing capabilities.

### [wycats/handlebars.js][handlebars]

### [tildeio/htmlbarss][htmlbars]

[stefanpenner]: https://github.com/stefanpenner
[ember-cli]: https://ember-cli.com
[rsvp]: //github.com/tildeio/rsvp.js
[bluebird]: http://bluebirdjs.com/
[when]: https://github.com/cujojs/when
[broccoli]: //github.com/broccolijs/broccoli
[broccoli-release]: https://www.solitr.com/blog/2014/02/broccoli-first-release/
[router]: //github.com/tildeio/router.js
[route-recognizer]: //github.com/tildeio/route-recognizer
[nh-route-recognizer]: //github.com/nathanhammond/ember-route-recognizer
[handlebars]: //github.com/wycats/handlebars.js
[htmlbars]: //github.com/tildeio/htmlbars
[promises]: https://promisesaplus.com/
[brocolli-deps]: https://libraries.io/npm/broccoli/dependents?page=1
[route-recognizer-example]: //github.com/hbrysiewicz/route-recognizer-example
[router-example]: //github.com/hbrysiewicz/router-example
