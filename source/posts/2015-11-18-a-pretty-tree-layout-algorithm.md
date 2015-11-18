---
layout: post
title: "Now that's a good-lookin tree"
twitter: dr_spaniel
github: drspaniel
author: 'Aaron Sikes'
tags: ember, best practices
social: true
published: true
---

In a recent project, i was asked to lay out a tree. It is a chain of
custody - these nodes have ancestors. There are merges and splits, all
backed by the block chain.

![A tree laid out by hand][mockup]
*"Just make it look like this" - The Designer*

Now, this is the kind of thing that's deceptively difficult. It's so
easy to throw something like this in a mockup, but it turns out it took
a fair amound of human insight to lay out that tree perfectly.

For example, there are two child nodes of that first generation that
only have one child each. One goes straight, but another moves two
notches up. How does an algorithm make that choice?

The two 100 nodes that split in two, how does an algortihm know they are
spaced far enough apart, that no children farther down the line will
collide?



[mockup]: http://i.imgur.com/4MmdiOM.png
