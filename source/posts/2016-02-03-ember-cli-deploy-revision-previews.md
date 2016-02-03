---
layout: post
title: "Setting up revision previews with Ember CLI Deploy"
author: 'Marten Schilstra'
twitter: 'martndemus'
github: martndemus
published: true
tags: ember
---

I recently set up previewing revisions with [Ember CLI Deploy][ember-cli-deploy].
There is no single best practice on how to do this yet, but here is how I did
it.

_This post assumes you use the
[ember-cli-deploy-revision-data][ember-cli-deploy-revision-data] plugin in
conjunction with an index adapter ([Redis][redis-index], [S3][s3-index],
[SSH][ssh-index]) for Ember CLI Deploy._

### About revisions

Everytime you deploy `index.html` with Ember CLI deploy, it gets tagged with a
revision. By default this is an MD5 hash of the `index.html` file itself, but it
can also be a Git commit hash, or the version from your `package.json`.

How exactly `index.html` gets tagged depends on the index adapter. For example:
using the S3 adapter, the tag will be appended to the filename; using Redis, the
tag will be part of the key where the file is stored.

Once you have one or more revisions deployed to the target server, you can
activate one of the revisions, which will be the default `index.html`
the users of your app will see.

### Viewing revisions without having to activate them

It would be very nice to be able preview a revision (maybe QA test) on the
production server, before you activate it and release it to the public. My idea
was to be able to do this by visiting
`https://example.com/rev-a76df687f97e9ab8ca82d1a1/`.

It is really simple to set up your webserver to do this, so I won't go into
that, but there is a caveat on the Ember side of this. If you navigate to the
revision, the router will throw an error: `The route rev-a76df687f97e9ab8ca82d1a1/
was not found`.

What is happening? The `Ember.Router` is not intelligent enough to know that you
meant to route after the `/rev-a76df687f97e9ab8ca82d1a1/` portion of the path.

You have to explicitly configure the router to route on a path other than `/`.

### Fixing the router

Setting up the router to work from a base path should be fairly straightforward,
for example to route on `/awesome-app/` you can set the
[`rootUrl`][ember-docs-root-url]:

```javascript
import Ember from 'ember';

const { Router } = Ember;

const Router = Router.extend({
  location: 'auto',
  rootURL: `/awesome-app/`
});
```

To route revisions is a little more complex, as you can't just type in a simple
string and be done with it. To be able to handle revisions, you can make the
`rootURL` a computed property instead:

```javascript
import Ember from 'ember';

const {
  Router,
  computed,
  isPresent
} = Ember;

const Router = Router.extend({
  location: 'auto',

  rootURL: computed(() => {
    let path = window.location.pathname;

    // Looks for /rev-a76df687f97e9ab8ca82d1a1/ at the beginning of the path
    // Tweak this regex to match your own style of revisions.
    let revisionMatch = new RegExp('^/(rev-[^/]+)').exec(path);

    // If there was a revision at the beginning of the path
    // return it as rootURL
    if (revisionMatch && isPresent(revisionMatch[1])) {
      return `/${revisionMatch[1]}/`;
    } else {
      return '/';
    }
  })
});
```

When the application loads, the `rootURL` computed property will be executed once.
If the `rev-*` part is in the path it will return that as the `rootURL`, else it
will just return the default `/`.

### Caveat: baseURL is set in ENV

By default the `baseURL` property in your `config/environment.js` is `/` and
does not interfere with the `rootURL` in the router, but when it is something
like `/awesome-app`, then you will run into trouble.

It is best to not use `baseURL` in conjunction with `rootURL`. If you have a base
path the app is served from, I would recommend you add it to the `rootURL`.

Here is how I solved it:

```javascript
import Ember from 'ember';
import config from './config/environment';

const {
  Router,
  computed,
  isNone
} = Ember;

const Router = Router.extend({
  location: 'auto',

  rootURL: computed(() => {
    let baseRootURL = config.baseRootURL || ''; // NOTE: This is not baseURL
    let path = window.location.pathname;

    let revisionMatch = new RegExp(`^${baseRootURL}/(rev-[^/])`).exec(path);

    if (revisionMatch && !isNone(revisionMatch[1])) {
      return `${baseRootURL}/${revisionMatch[1]}/`;
    } else {
      return `${baseRootURL}/';
    }
  })
});
```

### So now you know

If you have a backend that serves revisions on a scheme like
`/rev-a76df687f97e9ab8ca82d1a1/`, then this is one way to set up your Ember app
to work with that scheme. Don't forget to check your app's `baseUrl`.

If you figured out another way to set up something like this, then please share
it!

[ember-cli-deploy]: http://ember-cli.com/ember-cli-deploy/
[ember-cli-deploy-revision-data]: https://github.com/ember-cli-deploy/ember-cli-deploy-revision-data
[redis-index]: https://github.com/ember-cli-deploy/ember-cli-deploy-redis
[s3-index]: https://github.com/ember-cli-deploy/ember-cli-deploy-s3-index
[ssh-index]: https://github.com/green-arrow/ember-cli-deploy-ssh-index#readmehttps://github.com/green-arrow/ember-cli-deploy-ssh-index#readme
[ember-docs-root-url]: http://emberjs.com/api/classes/Ember.Router.html#property_rootURL
