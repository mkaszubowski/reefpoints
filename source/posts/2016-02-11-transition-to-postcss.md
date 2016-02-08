---
layout: post
title: "Why DockYard transitioned to PostCSS"
author: 'Cory Tanner'
twitter: 'ctannerweb'
github: ctanner
published: true
tags: CSS, PostCSS
summary: "DockYard's UX Development teams thought process behind transitioning to PostCSS"
---
The UX Development Team at DockYard takes pride in the ability to adapt to the latest tools that improve our workflow and benefit the team. We are always looking for tools that help with maintaining [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) CSS and quicken the development time of a project's CSS. Because of [PostCSS's](https://github.com/postcss/postcss) evolving plugin library, PostCSS is the latest addition to our development process.

PostCSS is the new [big kid on the block](https://twitter.com/PostCSS/status/689886395763179522) and for good reason. It has provided developers with modularity and flexibility in CSS development. The ability to add and remove plugins that fit a project's development process separates PostCSS from other tools that we used in the past.

#What we used in the past
In the past we used Sass for all our projects and utilized the parts of Sass that we needed. Along with Sass we used a combination of [BEM](https://css-tricks.com/bem-101/) and [SMACSS](https://smacss.com/) for naming conventions and file structure based on DockYard's styleguides.

When we began using Autoprefixer, we had to lay it on top of Sass. This meant that we had to manage multiple tools, which increased setup time.

We were using the best available tools within our workflow that we could at the time. As you know, it feels like a new development tool comes out every month. Over time, we felt we could improve the environment of how we were writing our CSS.

#Introducing PostCSS
PostCSS provides us with the flexibility to adopt new plugins with ease and within one NPM package that we manage at DockYard.

The PostCSS plugins we choose focus on two things. DRY CSS that does not trip over itself on overlapping styles, and creating organized CSS modules that have class names that explain themselves based on DockYard's [styleguides](https://github.com/DockYard/styleguides/tree/master/ux-dev).

We want developers who see our project tomorrow (or in two years) not to be confused by our naming conventions.

We use five PostCSS plugins in our projects. To get our projects up and running even easier, we combined them into a package called [narwin-pack](https://github.com/dockyard/narwin-pack).

- [postcss-partial-import](https://github.com/jonathantneal/postcss-partial-import)
- [postcss-nested](https://github.com/postcss/postcss-nested)
- [postcss-custom-properties](https://github.com/postcss/postcss-custom-properties)
- [postcss-svg-fragments](https://github.com/jonathantneal/postcss-svg-fragments)
- [autoprefixer](https://github.com/postcss/autoprefixer)

Those five plugins allow us to have modular CSS and use simple variables to speed up our development time. We are able to choose plugins that meet our development needs with no extra “bells and whistles”. What makes PostCSS so appealing is the ability to easily add and remove plugins from our custom made package.

We also have syntax rules that we follow while using these plugins - more on those in our next blog post going over each plugin in detail.
