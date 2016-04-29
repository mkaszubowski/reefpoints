---
layout: post
title: "Patterns from Ember Composable Helpers"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "A walkthrough of the patterns used in Ember Composable Helpers"
published: true
tags: Ember, JavaScript
---

Co-creator of Ember Composable Helpers [Lauren Tan][lauren] recently wrote about the [what, why and how][blogpost-lauren] of Ember Composable Helpers.
Now I'd like to talk about the patterns we have used to make Ember Composable Helpers work.

## The fundamentals of the Array helpers

Most of the array helpers are built upon the implementation of the [get helper][get-helper]. 
Let's take a closer look at a simplified version of the get helper:

```js
import Ember from 'ember';

const { 
  Helper, 
  get,
  observer,
  defineProperty,
  isEmpty,
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
    
    if (isEmpty(propertyPath)) {
      defineProperty(this, 'content', null);
      return;
    }
    
    defineProperty(this, 'content', oneWay(`targetObject.${propertyPath}`));
  }),

  contentDidChange: observer('content', function() {
    this.recompute();
  })
});
```

Let's start with the `compute` function on lines 12-17. 
It expects a `targetObject` and `propertyPath` param, which stand for the object you wan't to get the given property from.
These params are set as properties on the helper itself each time `compute` is called. Finally the `compute` function returns the `content` property. This will be the result of getting the `propertyPath` from the `targetObject`.

### Why not just return the given property from the target object?

Well, writing the helper as follows would have the downside that it will only recompute whenever the `targetObject` changes or when the `propertyPath` changes, but not when the desired property on the target object changes.

```js
import Ember from 'ember';

const { Helper: { helper }, get } = Ember;

export function getHelper([targetObject, propertyPath]) {
  return get(targetObject, propertyPath);
}

export default helper(getHelper);
```

### Solution: Observers



[lauren]: https://twitter.com/sugarpirate_
[blogpost-lauren]: https://dockyard.com/blog/2016/04/18/ember-composable-helpers
[get-helper]: https://github.com/jmurphyau/ember-get-helper/blob/master/addon/helpers/get-glimmer.js
