---
layout: post
title: "Announcing: ember-deferred-content"
comments: true
author: Dan McClain
twitter: "\_danmcclain"
github: danmcclain
social: true
summary: "Handling the states of async content"
published: true
tags: ember
---

There are times that you may have some content that you want to load
outside of the `model` hook. An example of this would be a blog post with
comments. You want your post to be loaded in the `model` hook of your
route, but don't necessarily want to wait for all of the comments to
load before displaying the blog post.

[ember-deferred-content][github] takes the promise you need to resolve to show
your content, and yields four subcomponents that you can use to show
content during the different states of your promise:

```hbs
{{#deferred-content promise=promise as |d|}}
  {{#d.settled}}<h2>Your content!</h2>{{/d.settled}}
  {{#d.pending}}Loading your content...{{/d.pending}}
  {{#d.rejected as |reason|}}<strong>Could not load your content:</strong> {{reason}}{{/d.rejected}}
  {{#d.fulfilled as |stuff|}}<strong>Loaded:</strong> {{stuff}}{{/d.fulfilled}}
{{/deferred-content}}
```

If you want to handle transitions with something like [liquid
fire][liquid-fire], you can use `if` (or `liquid-if`) statements and the flags provided:

```hbs
 {{#deferred-content promise=post.comments as |d|}}
    {{#if d.isSettled}} <h2>Comments</h2> {{/if}}
    {{#if d.isPending}} <img src="spinner.gif"> {{/if}}
    {{#if d.isFulfilled}}
      <ul>
        {{#each d.content as |comment|}}
          <li>{{comment.author}} said: {{comment.body}}
        {{/each}}
      </ul>
    {{/if}}
    {{#if d.isRejected}} Could not load comments: {{d.content}} {{/if}}
  {{/deferred-content}}
```

[Demo][demo-link]

As you can see above, you pass the promise to the `deferred-content` component,
then you get four contextual components for the four states of the promise:
`settled`, `pending`, `fulfilled`, and `rejected`. Each is a block component where the
content you place the content you want to see when the promise is in that
state. `rejected` and `fulfilled` yield the result of their states to the
component so you can reference the result of the promise.


## Let's take one step further

Let's peak at an example in which we have no asynchrony in our `model`
hook: [Example app][example-app]

So what's happening here? This app simulates a slow loading blog post.
We have some basic information on the blog list page (the title), and we
can use this to do a hero animation right away, instead of waiting for
the `model` hook to resolve. Clicking the deferred link shows that, as
clicking on the normal link waits for the model to be fetched in the
`model` hook before starting the transition.

### Deferring asynchrony to the template

When we use `deferred-content` to show the loading state note that the
URL update and animation happens immediately, as opposed to waiting for
the `model` hook to resolve. This approach will also encourage you to
model your data slightly differently so that you push your asynchronous
to logical divisions in your templates.

By utilizing animations to mask your loading times you improve your [perceived
performance][perc-perf]. Given that two sites take the same ammount of time to
render, the one with a loading animation will be perceived as
faster, and tends to be less likely to lose conversions.

### Where this really shines

Pages with multiple pieces of async content benefit the most from this
approach. You can load in each piece of content as you receive it,
making the page more responsive.

## Handle the states of your content easily

With `ember-deferred-content` it becomes trivial to handle async content after
rendering the page. You can provide a pending state to let your users know that
content is incoming, and switch over to the actual content once it's loaded.

[demo-link]: https://ember-twiddle.com/8ca7a5edd5ab0df72c0c?numColumns=1&openFiles=application.template.hbs%2C
[github]: https://github.com/danmcclain/ember-deferred-content
[example-app]: http://deferred-example.danmcclain.net/
[perc-perf]: http://blog.teamtreehouse.com/perceived-performance
[liquid-fire]:
