---
layout: post
title: "Productive debugging"
summary: "A peek into different debugging methods"
author: 'Romina Vargas'
twitter: "i_am_romina"
github: rsocci
published: true
tags: ember, javascript, testing
---

If you attended [Wicked Good Ember](https://wickedgoodember.com/) this past June,
it quickly became apparent that it was a Test Driven Conference - three
testing-related talks happened to be grouped together at the start of the
conference. It's clear that Ember developers care about testing. In fact, there
is an open [RFC](https://github.com/rwjblue/rfcs/blob/42/text/0000-grand-testing-unification.md)
to unify the way Ember does testing. I highly recommend reading it! Currently,
there are three different ways to test; one for each of the different types of
tests: unit, integration, and acceptance. However, while the unification becomes
reality, we must keep testing as usual, and I'd like to go over some quick tips
for debugging in the different test environments!

## pauseTest();

This first function is acceptance test specific, but according to the RFC, it
will eventually become available to use in all types of tests. When writing
tests, it's helpful to be able to inspect the state of the DOM. Inserting a
call to `pauseTest()` inside an acceptance test will pause the test suite at
the point that it sees the function call. This allows for developer interaction
with the current state of the application. Internally, `pauseTest()` returns a
promise that will never resolve.

```js
test('I can submit the contact form', function(/*assert*/) {
  visit('/contact-form');
  return pauseTest();

  // failing interaction
  click('button:contains("Submit")');
});
```

After running the above test on the browser, the test suite would pause once it
reaches L3. The application would be viewable exactly as it appears before
the `click` takes place.

_Example use case:_

I want to click the "Submit" button but my test is not finding that element,
therefore, it's failing. With `return pauseTest()`, I'm able to see that I'm not
actually in the expected `/contact-form` route, but that I'm being redirected to
the `/login` route. Now I can fix my test by logging in before visiting
`/contact-form`.

## assert.async();

This function is a favorite of mine, and I remember the excited when I first
learned about it a while ago (thanks [Marten][Marten]!). The use of
`assert.async()` is available to use in both acceptance and integration tests,
but it's currently the only way to pause an integration test Calling
`assert.async()` is similar to `pauseTest()`; you can inspect the state of the
DOM and play around with it while the test is paused. It's a great tool for
integration testing because much of the time, you're testing that certain
content/element appears on the page as a result of a user interaction. I find
it particularly useful to quickly find `class` names, `data-auto-id`s, etc,
instead of going back to the templates where they are defined.

This [`async()`][async] method comes for free with Qunit, which is Ember's
built-in testing framework.

```js
test('Clicking "Add contact" displays new contact form', function(assert) {
  this.render(hbs`{{contacts users=users}}`);
  click('button:contains("Add contact")');

  assert.async();

  // failing assertion
  let form = this.$('[data-auto-id="new-contact"]');
  assert.equal(form.length, 1, 'New contact form is displayed');
});
```

Like with the `pauseTest()` example, once the test runner reaches L5 above,
the test suite will pause and the current state of the DOM can be viewed.

_Example use case:_

I want to make sure that my new contact form is displayed on the page. I know
that the functionality is working, but my test is still failing. I can add a
call to `assert.async()` to check out the DOM. Turns out I was using the wrong
`data-auto-id`.

## debugger;

No debugging function left behind. There's no need to explain what `debugger;`
does, but when you need to debug some functionality without caring about what
the UI looks like, then you're good to place a `debugger;` call inside any test.

[Marten]: https://twitter.com/martndemus
[async]: https://api.qunitjs.com/async/
