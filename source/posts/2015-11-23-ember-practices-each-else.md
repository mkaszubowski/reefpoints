---
layout: post
title: "Ember Best Practices: Handlebars's Overlooked {{#each}} {{else}} Conditional Block"
social: true
author: Doug Yun
twitter: "dougyun"
github: duggiefresh
published: true
tags: ember, javascript, best practices
summary: "The Handlebars {{#each}} block trick that folks always forget"
ember_start_version: 1.10
---

In the past few months, my esteemed coworkers have written about [various
Ember best practices][best-practices]. To follow suit, I'd like to
reintroduce an often forgotten Handlebars trick.

How many times have you stumbled across a template that wrapped an
`{{#each}}` block with an outer `{{#if}}` conditional block?

## The Verbose

```hbs
{{! if-and-each-usage.hbs}}

{{#if footballTeams}}
  {{#each footballTeams as |team|}}
    Teamname: {{team.name}}
    City: {{team.city}}
    Mascot: {{team.mascot}}
  {{/each}}
{{else}}
  No teams to display!
{{/if}}
```

Logically, this makes sense. If there aren't `footballTeams` to iterate
through, we render out a message.

However, the result is an unnecessary conditional! Thankfully, the
`{{#each}}` block helper provides us with a more terse solution.

## The Succinct

```hbs
{{! each-else-usage.hbs}}

{{#each footballTeams as |team|}}
  Teamname: {{team.name}}
  City: {{team.city}}
  Mascot: {{team.mascot}}
{{else}}
  No teams to display!
{{/each}}
```

We don't need the outer `{{#if}}` block, and we simply can add an
`{{else}}` path within our `{{#each}}` block.

Although, the change here seems quite trivial, it immediately cleans
up readibility (which is a huge win in my book).

## More to Come

If you've enjoyed these [series of best practices][best-practices], stay tuned,
we'll be writing more posts soon after the holidays! Thanks!

[best-practices]: https://dockyard.com/blog/categories/best-practices
