---
layout: post
title: "Served with FastBoot (again)"
comments: true
author: Dan McClain
twitter: "\_danmcclain"
github: danmcclain
social: true
summary: "You are now reading a live FastBoot site"
published: true
tags: ember, fastboot
---

A little less than a year ago, we launched the redesigned DockYard.com,
which at launch was running an early version of [FastBoot][fastboot].
And by early version, I mean alpha version, when Ember had some memory
leaks, which caused FastBoot to crash. Since then, DockYard.com was a
*FastBoot Rendered, Statically Served*™ site. I would run a local
instance of FastBoot, use a custom crawler to crawl everything but the
blog and save static files of the site. I would then push those static
files to the server and let Nginx serve the files. This gained us the
benefits of running FastBoot (except on the blog), without FastBoot
running and crashing because of the memory leaks. The reason that the
blog was left out was because of the fact that using `{{{blog.body}}}`
was not rendered in that version of FastBoot, leaving the post content
of every blog post out of the page source.

## FastBoot keeps moving

As time went on, the memory leaks in Ember were fixed, and FastBoot has
been continually developed. Ember has also been updated so that stable
releases, as of 2.3.0, support FastBoot. Previously you had to use the
canary version and enable a feature flag to allow Ember to work with
Fastboot.

And recently, I revisited the DockYard site and worked to reimplement
FastBoot. In terms of work on DockYard.com, there was little to no work,
we had previously submitted pull requests to addons we were using to
make them FastBoot compatible. Most of the recent work was around
contributing to FastBoot to help make it easier for applications to drop
in.

There have been many contributors to FastBoot, helping to make it a
reality.  Ember Data, [as of 2.4.0][ember-data], works with FastBoot with little
configuration (you need to provide the `host` to your adapter for now,
as relative URLs do not work for FastBoot's AJAX layer).  There is a
[FastBoot service available to your Ember app that gives you access to
cookies][cookies], [headers][headers] and [the requested host in the FastBoot version of your
application][host]. DockYard.com may be a bit on the bleeding edge, but a
production version of FastBoot is not that far off.

If you and your company are looking for help getting your application
FastBoot ready we'd love to help. [Please reach out to us][contact].

[ember-data]: http://emberjs.com/blog/2016/03/13/ember-data-2-4-released.html#toc_fastboot-support
[cookies]: https://github.com/tildeio/ember-cli-fastboot/pull/121
[headers]: https://github.com/tildeio/ember-cli-fastboot/pull/123
[host]: https://github.com/tildeio/ember-cli-fastboot/pull/136
[fastboot]: https://github.com/tildeio/ember-cli-fastboot
[contact]: https://dockyard.com/contact/hire-us
