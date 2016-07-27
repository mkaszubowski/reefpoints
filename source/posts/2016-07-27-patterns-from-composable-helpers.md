---
layout: post
title: "Patterns from Ember Composable Helpers"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "A walkthrough of one of the patterns used in Ember Composable Helpers"
published: true
tags: Ember, JavaScript, Engineering
---

Co-creator of Ember Composable Helpers [Lauren Tan][lauren] recently wrote about the [what, why and how][blogpost-lauren] of Ember Composable Helpers.
Now I'd like to talk about one of the patterns we have used to make Ember Composable Helpers work.

## The fundament of the array helpers is the get helper

Most of the array helpers are built upon the implementation of the [get helper][get-helper]. 
Let's take a closer look at a simplified version of the `get` helper:

```js
import Ember from 'ember';

const { 
  Helper, 
  get,
  set,
  observer,
  defineProperty,
  computed: { oneWay }
} = Ember;

export default Helper.extend({
  compute([targetObject, propertyPath]) {
    set(this, 'targetObject', targetObject);
    set(this, 'propertyPath', propertyPath);

    return get(this, 'content');
  },

  propertyPathDidChange: observer('propertyPath', function() {
    let propertyPath = get(this, 'propertyPath');
    defineProperty(this, 'content', oneWay(`targetObject.${propertyPath}`));
  }),

  contentDidChange: observer('content', function() {
    this.recompute();
  })
});
```

Let's start with the `compute` function on lines 13-18. 
It expects a `targetObject` and `propertyPath` param, which stands for the object you want to get the given property from.
These params are set as properties on the helper itself each time `compute` is called. Finally the `compute` function returns the `content` property. This will be the result of getting the `propertyPath` from the `targetObject`.

## Why not just return the given property from the target object?

Well, writing the helper as follows would have the downside that it will only recompute whenever the `targetObject` changes or when the `propertyPath` changes, but not when the desired property on the target object changes.

```js
import Ember from 'ember';

const { Helper: { helper }, get } = Ember;

export function getHelper([targetObject, propertyPath]) {
  return get(targetObject, propertyPath);
}

export default helper(getHelper);
```

## Solution: Observers

Yes you heard it right, observers are a perfect candidate to solve the problem that our helper won't recompute when we want it to. So let's take a look at the `propertyPathDidChange` and `contentDidChange` observers.

```js
propertyPathDidChange: observer('propertyPath', function() {
  let propertyPath = get(this, 'propertyPath');
  defineProperty(this, 'content', oneWay(`targetObject.${propertyPath}`));
})
```

Let me explain what happens with this observer. On the first line we define an observer that will be triggered every time `propertyPath` gets updated. In the function body we get the value of `propertyPath` and use it to define a new computed property _at runtime_. We do that using [`defineProperty`][defineproperty]. This means that every time the `propertyPath`'s value changes, the `content` computed property gets redefined to point towards the correct path on the target object.

```js
contentDidChange: observer('content', function() {
  this.recompute();
})
```

Then there is the `contentDidChange` observer. This one watches for changes of the `content` property, which we define with the `propertyPathDidChange` observer. The `contentDidChange` observer calls `recompute`, which recomputes the end value of the helper.

## Putting it all together to create the map-by helper

Now that we know how to build a helper that can recompute when a property that we only know of at runtime changes, it is very simple to create other similar helpers upon this pattern. I'll leave you with the `map-by` helper, which doesn't look that different from the `get` helper I've shown you.

```js
import Ember from 'ember';

const { 
  Helper, 
  get,
  set,
  isEmpty,
  observer,
  defineProperty,
  computed: { mapBy }
} = Ember;

export default Helper.extend({
  compute([byPath, array]) {
    set(this, 'array', array);
    set(this, 'byPath', byPath);

    return get(this, 'content');
  },

  byPathDidChange: observer('byPath', function() {
    let byPath = get(this, 'byPath');

    if (isEmpty(byPath)) {
      defineProperty(this, 'content', []);
      return;
    }

    defineProperty(this, 'content', mapBy('array', byPath));
  }),

  contentDidChange: observer('content', function() {
    this.recompute();
  })
});
```

[lauren]: https://twitter.com/sugarpirate_
[blogpost-lauren]: https://dockyard.com/blog/2016/04/18/ember-composable-helpers
[get-helper]: https://github.com/jmurphyau/ember-get-helper/blob/master/addon/helpers/get-glimmer.js
[defineproperty]: http://emberjs.com/api/classes/Ember.html#method_defineProperty
