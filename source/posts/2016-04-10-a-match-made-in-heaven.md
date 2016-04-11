---
layout: post
title: "A Match Made In Heaven"
social: true
author: Estelle DeBlois
summary: "An example of how `ember-concurrency` could have helped reduce code complexity in a timer-heavy app."
published: true
tags: engineering, ember
---

Unless you've been living in a bubble, I'm sure you've all heard of [`ember-concurrency`][ember-concurrency-gh]. It's been all over Twitter; it's been brought up on Ember Weekend; it was even mentioned during this year's EmberConf keynote.

This past February, [Alex Matchneer][machty] gave us a walkthrough of his addon at the monthly [Boston Ember.js Meetup][boston-ember]. There is ample documentation and examples on the [website][ember-concurrency-docs] already, so I will forgo the details, but the TL;DR is that `ember-concurrency` offers an elegant way to write asynchronous, cancelable tasks in an Ember app. It also leverages the power of [generators][generators] so we can adopt a more readable, synchronous-like syntax.

I was unfortunately way too busy working on my talk for EmberConf at the time, that I didn't really get a chance to take the addon for a spin. But it was clear in my mind that the problems the addon addresses were the exact type of problems we had to solve in more traditional ways a year ago, as part of a client project.

It's a project I have brought up in the past when [demonstrating][ember-nw] the use of Ember in a NW.js-powered desktop app, but it just happens to also be a perfect candidate for `ember-concurrency`.

* Did we find ourselves having to invoke `Ember.run.cancel` to cancel previously scheduled tasks? Yes, indeed.
* Did we have to clean up asynchronous tasks in `willDestroy` hooks? Absolutely.
* Did we have to write guards to prevent an operation from running concurrently? For sure!

One of the goals of the app was to provide indoor cycling instructors with a better interface for managing and running a class, including a built-in roster and classroom map of which bikes riders had reserved, tools to start a class, start a race, view real-time stats and ranking, etc.

While we wrapped up the project a while ago, I felt compelled to recreate the elements that could have benefited from `ember-concurrency` in this (highly) simplified [demo app][demo-app].

To give a bit of context, a class runs for a specific amount of time, e.g. 1 hour. During that time, students can ride at their own pace. At various times during the session, the instructor may initiate a race that lasts 30, 45, or 60 sec. Racing occurs numerous times during a class, and one critical piece of information the app needs to convey to the instructor is how much time is left within any given race, as well as how much time is left before the end of a class. You don't want to accidentally start a 60 sec race if there's only 10 sec left of class time!

Let's take a look at the more traditional approach of managing a race timer with `Ember.run.later`.

We have a `race-panel` component that holds the race buttons for various race duration options. When a race button is pressed, the `race-panel` component's `startRace` action is invoked with the duration specified by the button itself (in seconds):

```js
// In app/components/race-panel/component.js
actions: {
  startRace(duration) {
    if (!get(this, 'isRaceInProgress')) {
      this.startTimer(duration);
    }
  }
}
```

The first thing we do is check whether a race is already in progress, as there can only be at most one active at any given time.

If the way is clear, we start the race timer. The main function here is `updateTimer`, which calls itself every second, each time decrementing the race counter, until we reach 0.

```js
isRaceInProgress: computed.gt('countdown', 0),

startTimer(duration) {
  set(this, 'countdown', duration);
  this.updateTimer();
},

updateTimer() {
  let timerId = run.later(() => {
    let countdown = this.decrementProperty('countdown');
    if (countdown > 0) {
      this.updateTimer();
    } else {
      this.stopTimer();
    }
  }, 1000);

  set(this, 'timerId', timerId);
},

stopTimer() {
  set(this, 'timerId', null);
},
```

The reason we need to store the ID of the operation started by `run.later` is so we can cancel it should the user navigate away (e.g. by aborting the class rather than let it run to completion). This means we also need to implement a `willDestroy` hook to do the clean up work:

```js
willDestroy() {
  let timerId = get(this, 'timerId');
  if (timerId) {
    run.cancel(timerId);
  }
},
```

The value assigned to the `countdown` property is used by the component to display a race timer in the instructor's UI.

This isn't rocket science, but if you consider the fact that we also need to disable race buttons depending on whether a race is already in progress, or disable specific race duration options depending on how much time is left in a class, all while keeping track of the class overall progress and possible early termination, this does end up being quite a lot of timer-related code to get right and maintain.

With `ember-concurrency`, the above can be simplified to just the following:

```js
raceTask: task(function* (duration) {
  let countdown = set(this, 'countdown', duration);
  while (countdown > 0) {
    yield timeout(1000);
    countdown = this.decrementProperty('countdown');
  }
}).drop()
```

The generator function allows us to write asynchronous code that feels synchronous, while the special `task` function lets us adhere to the idea of [structured concurrency][structured-concurrency].

We can instantiate the race task directly from the template, using the `{{perform}}` helper that the addon provides. In addition, figuring out if a race is in progress is just a matter of checking the value of `raceTask.isRunning`.

```hbs
{{#each raceDurations as |duration|}}
  <button disabled={{or raceTask.isRunning (gte duration classTimeRemaining)}}
      onclick={{perform raceTask duration}}>{{duration}}</button>
{{/each}}
```

Even though we are disabling the race buttons when a race is already in progress, having the option to use the `.drop()` task modifier in the component code guards us further against concurrent races in a more elegant way than if we had to do so via an internal property. The modifier ensures that future requests to run the race task will be dropped until the current one completes.

The best part, however, is that we no longer need those `willDestroy` hooks as `ember-concurrency` automatically manages the lifecycle of these tasks for us, so we can rest at ease knowing that when our component is destroyed, all tasks will be cancelled and cleaned up as well.

The result is a clear reduction in boilerplate code to manage asynchronous tasks and timers, as well as code that is much more readable overall. In short, I wish this had existed a year ago when we were still active on the project, but these sorts of asynchronous operations are common enough that they're sure to come up again. They don't have to necessarily deal with time-related events, as you can `yield` promises that hit some backend API as well, and let `ember-concurrency` handle the trickier concurrency or task cancellation logic.

[ember-concurrency-gh]: https://github.com/machty/ember-concurrency
[machty]: https://twitter.com/machty
[boston-ember]: http://www.meetup.com/Boston-Ember-js/events/228333385/
[generators]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function*
[ember-concurrency-docs]: http://ember-concurrency.com/
[ember-nw]: https://dockyard.com/blog/2015/03/26/bringing-ember-to-the-desktop-part
[demo-app]: http://brzpegasus.github.io/concurrency-demo/
[structured-concurrency]: http://alexmatchneer.com/ec-prezo/#/?slide=structured-concurrency-1
