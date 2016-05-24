---
layout: post
title: "{{component helper}}"
social: true
author: Romina Vargas
twitter: "i_am_romina"
summary: "Help optimize your code with the component helper, in conjunction
with other helpers"
github: rsocci
published: true
tags: ember, javascript, best practices, engineering
ember_start_version: 1.11
---

At DockYard, one pattern that we've been noticing in some of our projects is
needing to render different components based on some value. This value could
come from a computed property, a model attribute, etc. Typically, this means
that your template will contain some branching logic to figure out the
appropriate template to render. A helpful helper that became available pre-Ember
2.0 is the `{{component}}`. With its help, we can clean up our template logic.

A distinguishing factor between the `{{component}}` helper and the traditional
component invocation is that the helper expects the component name as the first
parameter following the helper name, and will dynamically render out the component
specified by that parameter. An arbitrary number of parameters may follow the
component name; these are what the rendered component expects.

`{{component myComponentName param2=param2 param3=param3 ...}}`

Suppose we have a `Food` model. And each `Food` model instance has a `taste`
attribute. We want to render a certain template depending on the string value of
`food.taste`. Prior to having the `{{component}}` helper, we'd do something like
the following:

```js
// food/component.js
import Ember from 'ember';
const { Component, computed: { equal } } = Ember;

export default Component.extend({
  isSpicy: equal('food.taste', 'spicy'),
  isSweet: equal('food.taste', 'sweet')
});
```

```hbs
{{! food/template.hbs }}

{{#if isSpicy}}
  {{food/spicy-food food=food}}
{{else if isSweet}}
  {{food/sweet-food food=food}}
{{else}}
  {{food/other-food food=food}}
{{/if}}
```

We defined a couple of computed properties and threw in some `if` statements
in our template to dictate which component to render based on the food taste.
But we can do better! Let's see how our app cleans up when using the helper.

```js
// food/component.js
import Ember from 'ember';
const { Component, computed, get } = Ember;

export default Component.extend({
  tastyComponentName: computed('food.taste', {
    get() {
      let foodTaste = get(this, 'food.taste');
      return `food/${foodTaste}-food`;
    }
  })
});
```

```hbs
{{! food/template.hbs }}

{{component tastyComponentName food=food}}
```

Nice. Our template became a one-liner, and we were able to remove the
computed properties that we had to define for each food taste that we
wanted to render a separate component for. All of the logic  is now consolidated
into one computed that returns the name of the component that should be rendered.
We can pass this property as the second argument inside `{{component}}`.  If we
wanted to later introduce new food tastes and components to go along with them,
no changes would need to be made in these two files, since `tastyComponentName`
takes care of all cases.

## More powerful templates

In the above example, we are using the computed property `tastyComponentName` to
name our template. But it's not immediately obvious what the template actually is
without looking at the computed property itself. We can forgo the CP altogether
and use Handlebars subexpressions to keep all logic within the template.

Recently, [Lauren][lauren] and [Marten][marten] released the
[ember-composable-helpers][ember-composable-helpers] addon whose aim is to make
logic in your Ember templates more declarative. How convenient that this addon
complements `{{component}}` well! The helpers within `ember-composable-helpers`
can be used in different combinations to format your component name depending
on your needs. Furthermore, Ember itself ships with some
[built-in helpers][ember-helpers] that can be used inside our templates as well.

The Ember helper `concat` is one of the helpers we use fairly often. It's
common to name components based on a value of an attribute. In our example,
the component name is based on `food.taste`. How would we modify our example
to make use of the `concat` helper?

```hbs
{{! food/template.hbs }}

{{component (concat "food/" food.taste "-food") food=food}}
```

And just like that, the `food/component.js` file is no longer needed. The `concat`
helper replaces the computed property entirely. If the value of `food.taste` is
`sweet`, then the helper will output `food/sweet-food`.

Another useful helper that works well in conjunction with `concat` is `dasherize`.
This helper is part of `ember-composable-helpers` addon and will take care of
lowercasing and dasherizing a given value. Sometimes, we have to work with camelized
values, and using `dasherize` will convert them to a more desired format. Here's
an example of how the helpers would be used together:

`{{component (concat "food/" (dasherize food.taste) "-food") food=food}}`

In this case, if the value of `food.taste` is `SuperSour`, then our rendered
component will be `food/super-sour-food`. With all the helpers we have available
to us, think of all the combination possibilities!

[lauren]: https://twitter.com/sugarpirate_
[marten]: https://twitter.com/Martndemus
[ember-helpers]: http://emberjs.com/api/classes/Ember.Templates.helpers.html
[ember-composable-helpers]: https://github.com/DockYard/ember-composable-helpers
