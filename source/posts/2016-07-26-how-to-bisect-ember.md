---
layout: post
title: "How to use git bisect by example"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "Learn how to use Git's bisect command with Ember.js as the example"
published: true
tags: git, javascript, ember
---

I'm writing this tutorial because I ran into a problem, while working on an addon, with Ember.js the other day. The problem was that the test suite did not pass anymore on Ember.js' canary build channel, while it used to pass before. After debugging the problem I wanted to find out which commit in Ember.js did break the tests. Thanks to [Robert Jackson](https://twitter.com/rwjblue), who pointed me to a [GitHub comment](https://github.com/emberjs/ember.js/issues/13846#issuecomment-234133694), I've been able to use `git bisect` to find the commit that introduced the issue and [report](https://github.com/emberjs/ember.js/issues/13888) it.

### What bisect does

`git bisect` uses the [bisection method](https://en.wikipedia.org/wiki/Bisection_method) to find the first commit that introduced the bug you are looking for. You will have to tell the bisect command one commit you are sure contains the bug and one commit that you are sure of that it does not contain the bug. Bisect will then start searching, asking you if a given commit it proposes is good or bad, until it has found the commit that introduces your bug.

### Setting up before the bisect

To find out what commit has introduced a bug in the [Ember.js](https://github.com/emberjs/ember.js) repository, you need to clone a different repository, that is [`components/ember`](https://github.com/components/ember), which contains the Bower builds of Ember.js. You can link this repo to your app directly and then use `git bisect` to find the first build that contains the bug. You can then cross-reference the build with the real Ember.js repo to find the actual commit that introduced the bug.

To clone and link the `components/ember` repository:

```
git clone git@github.com:components/ember.git components-ember -b canary
cd components-ember
bower link
```

Now you need to do a little bit of setup in the app that you are working with. You will need to modify your `bower.json` to use `components/ember#canary` for Ember.js and then link it to the local repository you just cloned. I recommend you do this in a seperate terminal window/tab, as you will have to go back and forth between this and the other a few times.

Example `bower.json` after the change:
```
{
  "name": "my-app",
  "dependencies": {
    "ember": "components/ember#canary"
  },
  "resolutions": {
    "ember": "canary"
  }
}
```

After updating your `bower.json` remove the installed Ember Bower component and link it to the local one.

```
rm -rf bower_components/ember
bower link ember
```

Now you're ready to start running `git bisect`.

### Finding the bad commit with bisect

From the `components-ember` folder start with running the `git bisect start` command, this will start your bisect session. Then run `git bisect bad` to tell the bisect session that the current commit is a bad commit. The next step is a little bit harder, you will need to find a commit that you are sure of to be good. One trick is to go back about six weeks (about one Ember version) in the history and pick a commit, this commit will have a high chance of being good. One warning though: going back too far might cause you to find a bug that is irrelevant to your case. When you have found such a commit, run `git bisect good <sha-of-good-commit>`. The response will look something like the following:

```
Bisecting: 117 revisions left to test after this (roughly 7 steps)
[4e1224de1687a86dc83936e880104b6b1a48bbe2] Ember Bower Auto build for https://github.com/emberjs/ember.js/commits/d2b56a290a45b23a792575dfa6e3af37cf58bc79.
```

This means that there are 117 commits left that can contain the commit you are looking for, and that it will take about 7 more steps to find it.

You should now notice that bisect has moved the `components-ember` repository to a different commit somewhere between your initial good and bad commits. In this case it is `4e1224de1687a86dc83936e880104b6b1a48bbe2` This is the first commit bisect has selected to test. It will wait for you to report if this commit is good or bad.

Now go back to your app's folder and run your tests (`ember test` for example). If all tests pass the suggested commit must be a good commit, run `git bisect good` in the `components-ember` folder to tell the bisect process that this commit is a good commit. If the tests fail, then run `git bisect bad` to tell the bisect process that this commit is a bad one.

After having specified if the commit is either good or bad bisect will respond with a similar message:

```
Bisecting: 58 revisions left to test after this (roughly 6 steps)
[73f02564972bbd14a719f707af019d94c822939c] Ember Bower Auto build for https://github.com/emberjs/ember.js/commits/1be0354068d933065ac542f49d42d73409366a47.
```

With this step it has eliminated 59 commits, and there are only 58 commits left that can contain the commit you are looking for. It has also moved the `components-ember` repository to the next commit that it needs you to test if it's good or bad.

Run your app's tests again and either run `git bisect good` or `git bisect bad` based on the results of the tests.

Keep repeating this process until it reports the bad commit:

```
9f6b98391523c4be437e1f6cd1a5956e69ecc0a9 is the first bad commit
commit 9f6b98391523c4be437e1f6cd1a5956e69ecc0a9
Author: Tomster <tomster@emberjs.com>
Date:   Sat Jun 11 00:03:22 2016 +0000

    Ember Bower Auto build for https://github.com/emberjs/ember.js/commits/b44f9dad912a73668dda142c34a6858283003403.
```

Congratulations! You have found the bad commit that introduced the bug that you were looking for. In this case it's `9f6b98391523c4be437e1f6cd1a5956e69ecc0a9`, and luckily the commit message includes the commit the build is from, so you can go to the GitHub url from the commit message and see the original commit.

### What if I wrongly report a commit as bad or good?

Unfortunately, bisect has no undo command, so you will have to start from the top again. To do this first run `git bisect reset`, this will end your bisect session. Now you can start over by running `git bisect start` and then marking a good and bad commit, which then will start the iterative process of marking commits selected by bisect good or bad again.

### Can I automate this a little bit more?

Yes you can! Bisect has the command `git bisect run`, which will run a command for you on each iteration. If the command succeeds it will mark the commit as good, if the command fails it will mark the commit as bad.

Let's take a look at how to do this with our example.

To reliably run the tests each iteration I added the following bash script to the `components-ember` folder, I called it `ember-bisect-test.sh`:

```
#!/bin/sh

cd <path/to/your/project/folder>
rm -rf bower_components/ember
bower link ember
ember test
```

Mark the file as executable:

```
chmod +x ember-bisect-test.sh
```

And now we can let bisect run your script on each iteration:

```
git bisect run ./ember-bisect-test.sh
```

### What have we learned?

You have now learned:
  - The basics of how `git bisect` works.
  - How to use `git bisect` with the Ember.js canary channel to track down commits that introduce regressions.
  - How to restart the process when you mess it up.
  - How to automate `git bisect` with a script.
