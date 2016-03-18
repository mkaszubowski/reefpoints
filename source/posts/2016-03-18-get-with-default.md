---
layout: post
title: "Ember's getWithDefault"
social: true
author: Michael Dupuis
twitter: "michaeldupuisjr"
github: "michaeldupuisjr"
summary: "A quick look at a common gotcha."
published: true
tags: ember, javascript, best practices
---

## Getting Default Values
Here's a quick look at a common gotcha that slips into pull requests
from time to time.

When working in Ember, you'll often want a default value for
certain properties. Ember provides a convenient means for getting a
default value with the aptly named, [`getWithDefault`][getWithDefault]:

```javascript
Ember.getWithDefault(person, 'lastName', 'Doe');
```

The above code would retrieve the `lastName` property off of the
`person` object, and if the value is `undefined`, it will return
`Doe`.

## An Example
Let's say we're working on a campaign application with a `Donation` model. This
app will primarily be used by [Super PACs][super-pacs] to fund campaigns
of legislators who represent the interests of a small group of deep-pocketed
individuals. These well-funded legislators will [win their elections
about 90% of the time][money-in-elections].

Naturally, if the donor does not disclose her name, 
the Super PACs would like the default donation to display "Anonymous."

Our first pass looks something like this:

```javascript
// app/donation/model.js

import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import computed from 'ember-computed';
import get from 'ember-metal/get';

export default Model.extend({
  amount: attr('number'),
  fullName: attr('string'),

  displayName: computed('fullName', {
    get() {
      return get(this, 'fullName') || 'Anonymous';
    }
  })
});
```

We soon realize we can clean up our `displayName` computed property with `getWithDefault`:

```javascript
displayName: computed('fullName', {
  get() {
    return getWithDefault(this, 'fullName', 'Anonymous');
  }
})
```

Using `getWithDefault` in that example is a bit cleaner and easier to
read.

Then one day, we wire up with a new, external API. The JSON payload from this backend
sends `null` for `fullName` if the record does not have a
value. Our `displayName` no longer defaults to "Anonymous" and we're
slightly confused. If our `fullName` value is falsy, why does
`getWithDefault` not return our default value?

Remember, `getWithDefault` is not evaluating
whether or not the return value is truthy or falsy: it only returns the
default value if the `get` returns `undefined`. The value that was once
`undefined` is now `null`, so `getWithDefault` returns `null`.

The solution here is probably to cleanup the JSON payload in the
serializer so that `null` values are treated as `''`. 
But for this contrived example, and for any instance in
which you would like to set a default value based off a falsy return
value, use a good, old-fashioned `or` operator:

```javascript
displayName: computed('fullName', {
  get() {
    return get(this, 'fullName') || 'Anonymous';
  }
})
```

I hope this prevents a few people from scratching their heads when
`getWithDefault` doesn't behave as expected.

Thanks for reading, and
don't forget to support campaign finance reform this tax season by
opting into the [Presidential Election Campaign Fund][pecf] (it's free)!

[getWithDefault]: https://github.com/emberjs/ember.js/tree/v2.4.0/packages/ember-metal/lib/property_get.js#L152
[super-pacs]: https://www.opensecrets.org/pacs/superpacs.php
[money-in-elections]: http://www.opensecrets.org/news/2008/11/money-wins-white-house-and/
[pecf]: https://en.wikipedia.org/wiki/Presidential_election_campaign_fund_checkoff
