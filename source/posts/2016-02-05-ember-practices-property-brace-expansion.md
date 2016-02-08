---
layout: post
title: "Ember Best Practices: Brace Expansion for Computed Properties"
social: true
author: Doug Yun
twitter: "dougyun"
github: duggiefresh
published: true
tags: ember, javascript, best practices
summary: "DRYing up computed properties since 2014"
ember_start_version: 1.4
---

As an Ember developer, I can count on fresh features popping up almost every
other month within a new release. There are numerous benefits to this, which
certainly are out of the scope of this blog post. However, I will briefly
cover one particular gem from 2014 - an oldie, but goodie - of a feature.

How many times have you written something like this?

```js
import Ember from 'ember';

const {
  Component,
  computed
} = Ember;

export default Component.extend({
  farmSentence: computed('animal.species', 'animal.noise', 'farmer.name', 'farmer.location', {
    get() {
      let animal = get(this, 'animal');
      let farmer = get(this, 'farmer');

      return `At ${get(farmer, 'location')}, Farmer ${get(farmer, 'name')} owns a ${get(animal, 'species')} that says "${get(animal, 'noise')}!"`;
    }
  })
});
```

Notice how we consume `animal.species`, `animal.noise`, `farmer.name`, and `farmer.location`?
There are a lot of *shared* dependent keys. Gross.

## Computed Property Brace Expansion

Well, [back in 2014, "brace expansion" was introduced][brace expansion].
Let's use this feature and tidy up our component!

```js
import Ember from 'ember';

const {
  Component,
  computed
} = Ember;

export default Component.extend({
  farmSentence: computed('animal.{species,noise}', 'farmer.{name,location}', {
    get() {
      let animal = get(this, 'animal');
      let farmer = get(this, 'farmer');

      return `At ${get(farmer, 'location')}, Farmer ${get(farmer, 'name')} owns a ${get(animal, 'species')} that says "${get(animal, 'noise')}!"`;
    }
  })
});
```

## Why use Brace Expansion?

Isn't that much nicer? I prefer using brace expansion, because it **organizes** the dependent keys and
makes it **easier to read**. Goodness forbid a coworker of yours writes dependent keys without ordering
them alphabetically:

```js
...

// This ordering isn't ideal
farmSentence: computed('animal.noise', 'farmer.name', 'animal.species', 'farmer.location', {
  get() {
    let animal = get(this, 'animal');
    let farmer = get(this, 'farmer');

    return `At ${get(farmer, 'location')}, Farmer ${get(farmer, 'name')} owns a ${get(animal, 'species')} that says "${get(animal, 'noise')}!"`;
  }
})

...
```

To those new to Ember, hope you learned something new!
And to those experienced in Ember, hope this was a refresher!
And to my coworkers that don't use brace expansions, shame on you!

Thanks for reading.

[brace expansion]: http://emberjs.com/blog/2014/02/12/ember-1-4-0-and-ember-1-5-0-beta-released.html#toc_property-brace-expansion)
