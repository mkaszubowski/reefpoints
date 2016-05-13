---
layout: post
title: "narwin-pack a PostCSS package"
social: true
author: Cory Tanner
twitter: "ctannerweb"
summary: "After DockYard’s recent transition to PostCSS, we realized that we needed a bit more plugin organization. So we created narwin-pack. Here’s an overview of the plugins that make up narwin-pack and why our UXD team chose each PostCSS plugin."
published: true
tags: PostCSS, CSS
---

In my last blog post, [Why DockYard transitioned to PostCSS](https://dockyard.com/blog/2016/02/11/transition-to-postcss), I explained why our UXD team adopted [PostCSS](https://github.com/postcss/postcss) into our development process.

During the transition process we realized it would be best to only use PostCSS plugins that meet two criteria:
- Encourages DRY CSS
- Simplifies our development process

That’s when [narwin-pack](https://github.com/DockYard/narwin-pack) was born, An easy-to-use PostCSS package that holds all six of our plugins in one easy-to-use package.

Having many plugins bundled into one package that can easily be included in our projects is valuable to our team. It gives our UXD team a structured environment in which to develop CSS.

If another UX developer wants to add a plugin to narwin-pack a discussion is had within the narwin-pack repository and we discuss the pros and cons of using that plugin. If everyone agrees that a plugin is needed then it will be added to narwin-pack.

PostCSS has options for hundreds of plugins that you can include in your project. Having only one package to use for our projects provides consistency, knowing that every developeri within out team will be using the same plugins.

The plugins in narwin-pack are as follows:

- [postcss-partial-import](https://github.com/jonathantneal/postcss-partial-import)
- [postcss-custom-properties](https://github.com/postcss/postcss-custom-properties)
- [postcss-nested](https://github.com/postcss/postcss-nested)
- [postcss-calc](https://github.com/postcss/postcss-calc)
- [autoprefixer](https://github.com/postcss/autoprefixer)
- [postcss-svg-fragments](https://github.com/jonathantneal/postcss-svg-fragments)

# 1. postcss-partial-import

The postcss-partial-import plugin provides a modular CSS file structure. You can have multiple CSS files and then with the help of postcss-partial-import we merge all our CSS files into one central file that the browser will use.

The ability to have multiple CSS files but only reference one CSS file in our HTML is important for page performance. The browser now only has to ask the server for one CSS file. At the same time using multiple CSS files lets us modularly organize our CSS based on BEM [naming conventions](https://github.com/DockYard/styleguides/blob/master/ux-dev/class-naming-conventions.md) and SMACSS file architectures.

Modular CSS file structure:

```css
styles/
    modules/
        header.css
        footer.css
        nav.css
    base.css
    load.css
    layout.css
    type.css
```
Using this CSS architecture we can now add all of those CSS files into one central CSS file. Our CSS file with `@imports` to the other CSS files could look like the following:

```css
@import: "load.css";
@import: "type.css";

@import: "modules/header.css";
@import: "modules/footer.css";
```
The plugin will recognize the `@import` and add the contents of the referenced CSS files into this one CSS file.

![](http://i.imgur.com/x6596A7.jpg)

# 2. postcss-custom-properties

Who doesn’t love using variables!

The use of variables in CSS has been a hot topic lately, and eventually all browsers support will them. Firefox and chrome already have [support ](http://caniuse.com/#search=variables), but we are still waiting on Edge and mobile browser support. Until all browsers support variables, we will need a plugin.

I think most developers would agree with me when I say that I would rather remember a color for its name, as opposed to its hex code. Further, we make sure to organize our variables with naming conventions so they are easy to both read and use.

An example of how we organize our variables in our `load.css` file is as follows:

```css
:root {
  /* COLORS */
  --white: #FFFFFF;
  --green: rgb(61, 154, 104);
    --75-green: rgba(61, 154, 104, .75);

  /* FONT WEIGHTS */
  --light: 200;
  --bold: 600;
}
```
Notice that we break our variables down into sections and give them easy to use names with indentation this way, other developers can look at this CSS file and know what everything does.

An important thing to remember is that if you want your variables to be used globally, you should wrap variables in a `:root {}`.

Here’s a quick example of how to use variables:

```css
:root {
  --green: rgb(61, 154, 104);
}
```
In other CSS files, you can just use the variable name in place of the color code.

```css
color: var(--green);
```
The output of this will be the rgb color code. This is simple but allows us to organize colors and other variables.

# 3. postcss-nested

Nesting is a technique that we use, but in moderation. We make sure not to nest class names for easier “BEM-ing” because it can be difficult to try to find BEM classes that have been made with nesting. We can’t search for `.hero__heading` if `__heading` was added to `.hero` with nesting.

Incorrect Example:

```css
.hero {
  margin-top: 10px;
  &__heading {
    color: blue;
  }
}
```
Using BEM’s naming conventions without nesting keeps our CSS files readable and searchable.

Correct Example:

```css
.hero {
  margin-top: 10px;
}
.hero__heading {
  color: blue;
}
```
We do use nesting for media queries, pseudo elements/classes and parent dependent classes styles.

Example:

```css
.nav__links {
  float: right;
  .body--black & {
    border-color: var(--white);
  }
  .body--white & {
    border-color: var(--black);
  }
}

.nav__link {
  color: var(--green);
  &.is-active,
  &:focus,
  &:hover {
    color: var(--50-green);
  }
  @media (max-width: 599px) {
    display: block;
  }
  @media (min-width: 600px) {
    display: inline-block
  }
}
```
The block of CSS above is a simple example of good nesting according to the guidelines we have set for ourselves.

# 4. postcss-calc
Having this plugin included in narwin-pack is a result of having postcss-custom-properties. With this plugin we can include variables inside `calc()` equations if we would like.

Input:

```css
:root {
  --font-size: 18px;
}
```

Any CSS file within the same root folder:

```css
font-size: calc(var(--font-size) * 2);
```

Output:

```css
font-size: 36px;
```

# 5. postcss-svg-fragments

A downside of using the [symbol](https://css-tricks.com/svg-symbol-good-choice-icons/) method for multiple SVG is that you can not use it in CSS, only inline HTML. SVG Fragments solves this problem for us.

Without this plugin, we would need to have individual SVG files for background-images in CSS, and the browser would have to pull multiple SVG files when loading a page. The plugin postcss-svg-fragments solves this by doing what its name implies it adds SVG fragments into CSS.

We take all our SVG files and add them to [icomoon.io](https://icomoon.io/app/#/), generate a new SVG that uses `` with a unique `id`. When we add the new SVG code to our `defs.svg`.

Input:

```css
background-patter {
  background-image: url(defs.svg#pattern);
  fill: blue;
  stroke: black;
}
```

Output:

```css
.background-patter {
  background-image: url(/* SVG data */);
  fill: blue;
  stroke: black;
}
```

# 6. autoprefixer

One of the most used tools by HTML/CSS developers is autoprefixer. Before having autoprefixer as a PostCSS plugin, we would go to [caniuse.com] to see what CSS rules still needed browser prefixes. Even developers who don’t use PostCSS use the autoprefixer plugin in their projects.

Now, we have a plugin that looks at our CSS and searches for what prefixes are needed and adds them into the compiled CSS file according to how it’s configured. Autoprefixer also lets us configure custom browser support.

Example with autoprefixer:

```css
.block {
  display: flex;
}
```

Output:

```css
.block {
  display: -webkit-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display: flex;
}
```

# Takeaways

We choose these plugins because they are intended to make our lives easier as developers. Further, these plugins will help us develop DRY and efficient CSS, which is significant because that is the interface with which the user will interact.

If chosen carefully, the combination of plugins and self-set guidelines can foster a great environment in which to make exceptional CSS.
