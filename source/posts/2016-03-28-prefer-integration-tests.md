---
layout: post
title: "Prefer Integration Tests over Acceptance Tests"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "Integration testing should be an integral part of your test suite."
published: true
tags: ember, javascript, testing
---

It is suprisingly easy to test your whole Ember.JS application using acceptance tests only. All you have to do is to reproduce how you would normally navigate through the application using a [stellar set of helpers](https://guides.emberjs.com/v2.4.0/testing/acceptance/). Don't want to test your API? [Add ember-cli-mirage](http://www.ember-cli-mirage.com)!

You should realize though, that each acceptance test boots up the whole Ember.JS application and starts you at the `application.index` route. You then have to navigate to the right page and then test the thing you wanted to do. This is fine when you want to test a complex user-flow through an app, but a big waste of time and CPU cycles to verify if a form submit button is unclickable when the data is invalid.

If you create acceptance tests for every edge case and every regression, then it will be likely that your test suite will quickly grow to be five, ten or more minutes long. That is a problem since slow test suites are likely to be run less often by the developer, and test failures won't be caught quickly. I have caught myself relying on the CI server to run the tests for me, while doing other stuff, because I didn't want to wait for just five minutes.

Having said all that, I think we should write more integration tests and less acceptance tests. Integration tests in most cases run much faster, because you don't have to boot a whole app, or navigate to the page where your component is being used.

Integration tests are also more flexible than most people think. They're not only for testing components, you can also test [template helpers](https://github.com/DockYard/ember-composable-helpers/blob/master/tests/integration/helpers/map-by-test.js). Actually you can test anything with an [integration test](https://github.com/switchfly/ember-test-helpers/blob/master/lib/ember-test-helpers/test-module.js#L26). For example a model that has logic depending on its relationships is a good example where you can use a non-component integration test.

Using component integration tests to test components should also improve your component design. Test driving individual components will make you think more about their external API, prevents building a [LMAO](http://slides.com/miguelcamba/composable-components#/8) and promotes [loose coupling](https://en.wikipedia.org/wiki/Loose_coupling).

There is, however, a small downside to integration tests: the API for writing component integration tests is completely different than the api for writing acceptance tests, so you will have to learn another totally different style of writing tests while maintaining the knowledge of how to write acceptance tests. Luckily there is a [motion to unify](https://github.com/emberjs/rfcs/pull/119) the API for integration and acceptance tests.

If you aren't that familiar with EmberJS' integration tests I'd recommend to read Alisdair McDiarmid's [Ember component integration tests](https://alisdair.mcdiarmid.org/ember-component-integration-tests/) post.

Closing out I'd like to say that this post isn't mean't to say don't do any acceptance testing anymore. Acceptance tests are still necessary to smoke test the whole application.
