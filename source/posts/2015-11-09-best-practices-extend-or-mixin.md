---
layout: post
title: "Ember Best Practices: Extend vs Mixin"
social: true
author: Romina Vargas
twitter: "i_am_romina"
github: rsocci
published: true
tags: ember, javascript, best practices
ember_start_version: 1.13
---

Code duplication: can’t live with it, _can_ live without it. As
developers, we’re always trying to find ways to DRY up our code. No
matter how big or how small an application, code duplication manages to
sneak its way into your files. So far in this Ember best practices series, we’ve
learned how to write [DRYer computed properties][mike] and [DRYer tests][lin]. What
about more general application code?

In Ember, there are two main concepts that we can adapt in order to
share code between different parts of our application: `Ember.Mixin` and
`Ember.Object.extend()`. Both of these essentially achieve the same end
result, but depending on the scenario, one may be a better bet. Let's look at a
brief overview of each one.

## Ember.Object.extend()

Deep down, all Ember objects that we create and interact with are an extension of the
`Ember.Object`. `Ember.Object` itself extends [Ember.CoreObject][core], which
includes the [Ember.Observable][observable] mixin, and it's what gives Ember its "properties and
property observing functionality." Without these base objects, there would be no Ember.

We can create a new _subclass_ by calling the `extend()` method on any Ember
object. This will give the new subclass all of the properties of the parent class,
as well as any properties defined in the new one. You're also allowed to
overwrite any properties found in the parent by defining them in the new class.
If you've written an Ember App, you will be familiar with the following:

```js
// routes/index.js

export default Ember.Route.extend({
  // properties and methods
});
```

In this case, `IndexRoute` will inherit properties, methods, and
anything else defined in the `Ember.Route` object, as well as everything down
its prototype chain:

`IndexRoute` **->** `Ember.Route` **->** `Ember.Object` **->** `Ember.CoreObject`

Keep in mind that any properties defined in the parent object will be shared
among any child object. For this reason, you may want to
initialize certain properties inside the `init` constructor, which gets called
whenever an instance of an object gets created. This way, each object instance
gets its own unique set of properties.

## Ember.Mixin

Unlike the `Ember.Object`, mixins don’t get extended. Instead, they get
created via `Ember.Mixin.create()`. When we include the mixin inside an
Ember object, we’re extending the constructor’s prototype. What this
means is that like using `extend()`, any properties or functionality that is
defined inside the mixin will be shared among all classes containing this mixin.

```js
// mixins/foo.js
export default Ember.Mixin.create({
  bars: []
)};
```

```js
// components/A.js
import FooMixin from ‘../mixins/foo’;

export default Component.extend(FooMixin);
```

```js
// components/B.js
import FooMixin from ‘../mixins/foo’;

export default Component.extend(FooMixin);
```

The above will result in both component A and component B sharing the same
`bars` array. Any changes made to the array will be reflected in both
components. If you want to play around with this sharing business,
you can go [here][jsbin]!


## Mixin me, Mixin me not...So which do I use?

Ultimately, the decision will differ on a case by case basis. We can think of
it in terms of inheritance vs composition.

A base class can usually live on its own or be extended. Inheriting from a parent
object will provide the child with the full functionality of the parent, plus any
additional properties and behavior that are specific to the child. _The child should
behave like the parent_. Extending works well when you need several variations of
a parent object. Take a form, for example. You may have differing templates,
but will have mostly the same component logic. Extending each component from a base
class would make sense, and their own component-specific properties would be
defined in the new subclass.

The thing about mixins is that they encapsulate succint pieces of
functionality. The code that they contain can be reused throughout different
parts of the application, and is not a concern of any one route, controller,
component, etc. They're also meant to be used with other objects, not as
a stand alone piece; they don't get instantiated until you've passed them
into an object, and they get created in the order of which they're passed in.
Mixins can help to avoid long chains of inheritance and adds flexibility if the
need for making changes arises.

### Mixin example, plz

A good candidate for a mixin? Pagination! Pagination logic is not very
extensive and it can be sprinkled throughout an application. Applications
tend to need pagination for displaying a number of things; a mixin provides
us with the ability to add this to different routes, without caring about
the type of model or object that we're trying to display on the page.
Let's say we have the following routes:

```js
export default Ember.Router.extend({
  this.route('authors');
  this.route('blog', function() {
    this.route('comments');
  });
});
```

All of these routes need to have pagination built-in. Even though the routes
are not related, we can utilize the same pagination mixin for all of them. Each
of these three routes will have to include the mixin like so:

```js
import PaginationMixin from '../mixins/pagination';

export default Route.extend(PaginationMixin);
```

### Extend example, plz

A good candidate for extension? Authentication! More often than not, we need two
different types of routes: authenticated and unauthenticated. The best way to
handle this is to create a base class for each of those (or just one,
depending on your needs!), and extend the routes which need the particular
functionality. If we have the following routes,

```js
export default Ember.Router.extend({
  this.route('blog');
  this.route('account', function() {
    this.route('profile');
    this.route('settings');
  });
});
```

```js
// routes/authenticated.js

export default Ember.Route.extend({
  // check for session & transition accordingly
});
```

in `account/index.js` we would just extend `authenticated.js`

```js
// account/index.js

import AuthenticatedRoute from 'routes/authenticated';

export default AuthenticatedRoute.extend();
```

Doing this will make sure that `account` and any child route is off limits to
users who are not signed in. We simply apply this same pattern to any other
parent routes that need authentication. If we were to use a mixin instead, we
would end up with having to import the mixin all over the application - and
you're more likely to forget to add it.

## Sum it up!

Hopefully this has helped in better understanding the differences between using
`Ember.Object.extend()` and `Ember.Mixin` as it's not always black or white on
whether to use one concept over the other. Ask yourself what the intent of the code is,
where and how often it's going to be used, and make your best judgement. All
in all, stay DRY!

[mike]: https://dockyard.com/blog/2015/10/23/ember-best-practices-dynamic-dependent-keys-for-computed-properties
[lin]: https://dockyard.com/blog/2015/09/25/ember-best-practices-acceptance-tests
[core]: http://emberjs.com/api/classes/Ember.CoreObject.html
[observable]: http://emberjs.com/api/classes/Ember.Observable.html
[jsbin]: http://emberjs.jsbin.com/nakube/2/edit?html,js,output
