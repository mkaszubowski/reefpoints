---
layout: post
title: "CSS Dev Conference 2015 Thoughts"
summary: "Brief thoughts on my experience at CSS Dev Conference and all my notes"
comments: true
author: Cory Tanner
twitter: ctannerweb
github: ctannerweb
social: true
published: true
tags: conference, css, html
---

As a UX Developer I specialize in HTML/CSS so a CSS developer conference could not have been any more perfect. Three DockYarders, including myself, had the opportunity to go to [CSS Dev Conf](http://2015.cssdevconf.com/) last week aboard the Queen Mary in LA.

The talks went beyond my expectations and I learned something different at each one. Even with new content being presented it was good to see that the tools and opinions of the speakers were all aligned with how we structure HTML/CSS at DockYard.

The most interesting event at the conference was the open question session at the end of day 2. All the speakers got on stage at once and the audience could go to a microphone in the middle of the room and ask the group any question that came to mind. There were some great insights shared about what CSS developers should expect to see from the job market and what the future of CSS will look like.

The Queen Mary was amazing to stay on throughout the conference and I have to give a shoutout to left shark, right shark and the giant octopus at the after party. Could not have asked for a better venue. Who wouldn't want to go to a conference on a boat?!

Here are my takeways from the conference!

# Keynote Sara Soueidan
Twitter: [@SaraSoueidan](https://twitter.com/SaraSoueidan)

Slides: [SVG For Web Designers (and Developers)](http://www.slideshare.net/SaraSoueidan/svg-for-web-designers-and-developers)

- Use SVGs for everything possible and provide fallbacks for browsers that need it
- Keep in mind you need to look at performance, don’t choose SVGs over performance

## SVG for…
- Icon systems
- Add banners
- Infographics
- Data visualizations
- Animated illustrations
- Filter effects
- Simple UI shapes

## Future
- CSS Spec custom add SVGs rules coming soon

## Designing SVGs
- Every design decision that is made while designing an SVG affects development
- Developers and Designers need early communication and have some give and take to make both their lives simpler

## Process
- Outline text that has been changed into vectors are not selectable
- Outline text preserves font-face
- Use simple shapes over a `<path>`
  - easy to maintain
- Simplify your paths when you use them with simplify path tool in Illustrator
- Only combine paths if you don’t need sections to be separate for animation or coloring
- Use organized naming/layer conventions in your SVG code
- Designers should use SVGs filters that are available in Illustrator effects section
- Always keep `width` and `height` attributes on the `<svg>`
  - Great for fallback

## Optimize
- Most popular tool is SVGO but will change the structure of the SVG, also can break your SVGs :( so use the GUI version with custom options
- Optimizing your SVG can cut your files size by half
- Illustrator in the future will have optimize options
- Sketch has no options yet :(

## Development
- `<symbol>` and `<use>`
  - Multiple `<symbol>` elements being combined into one SVG, always include `<title>` and `description` for accessibility
  - This technique puts the SVGs code in a shadow DOM that is difficult to style
  - You can leak styles in with CSS variables `var(--prime-color)`
- Use SVGs `viewbox` to create a view window that only shows a portion of the SVGs file. Also known as the sprite technique
  - Place your SVG files into the CSS as background-images
  - support back to IE6
- Use CSS only for simple animations
- Use JS for complex animations

## SVG over icon fonts
- Infinite scale and easy styling
- Browser content blockers will block fonts and not SVGs
- Tools for switching from icon-fonts to SVG are out there.
- [Greensock](http://greensock.com/get-started-js) animation library is a go-to
- `<object>` is most flexible embedding technique for SVG

# Cracking the SVG Code: Brenda Storer
Twitter: [@brendamarienyc](https://twitter.com/brendamarienyc)

Slides: [Cracking the SVG Code](http://brendastorer.com/presentations/2015-10-CSSDevConf-SVGs/#intro)

- Queen Mary is in the top 10 most haunted places in the world. Over 150 spirits on the boat
- Whats inside a SVG? XML!
  - It's like HTML but for digital drawings instead of content
- SVG 1.0 became recommended in 2001 by W3C
- SVG 2.0 maybe in 2018 :)
- `viewBox` defaults to px if no value is given
- `viewBox="0 0 100 100"` start x start y end x end y
- For inline SVG remove all unneeded markup that is inserted by Illustrator
- `<g>` is the `<div>` of SVGs
- Stroke = CSS border and fill = CSS background-color
- GO Shapes! `<rect>`, `<circle>`, `<ellipse>`, `<line>`, `<polyline>`, `<polygon>`
- In Illustrator you can select what you want to be a SVG and then shorthand copy it, then paste in your text editor
  - This also starts your `viewBox` at 0 0 !!!
- Transforms on SVG is not 100% supported with your .css file but if you include the transform inline style its 100% supported
- Checkout [SVG Compressed](http://www.amazon.com/jQuery-Compressed-Jakob-Jenkov-ebook/dp/B006DI6QJ2/ref=asap_bc?ie=UTF8) book online

# Creative Typography with SVG: Brenna O’Brien
Twitter: [@brnnbrn](http://twitter.com/brnnbrn)

Slides: [Creative Typography With SVG](http://talks.brennaobrien.com/svg-typography/#/)

- VREAM - viewBox Rules Everything Around Me
- SVG easy to manipulate with CSS and JS
- Text becomes completely responsive when inside a SVG
- Go on a code adventure with SVG you will find new things

## SVG has a `<text>` element
- `<text>` is accessible!
  - Inherits font-family from `<body>`
  - Use fill to change color
  - `y="0"`is not good, use `y=“1em”`
  - `font-size="80"` is 80px

## `<tspan>`
- similar to `<span>`
- use `x` and `y` for positioning

## Curved text
- use `<textPath>` and then link it to a `<path>` that is inside your `<defs>` with a `xlink:href="pathName"`

## Gradients on text
- `<linearGradient>` in your `<defs>`
- In your `fill` on the `<text>` use `fill=“url(#grad)”`

## Images on text
- Can put your `<image>` inside a `<pattern>` under your `<defs>` and apply the pattern to the fill on your `<text>`
- You can also fill text with gifs :)

## Knockout text
- Place your `<text>` in a `<mask>` and then apply the mask to your element you want the text to be in as `mask="url(#knockoutText)"`

## Self Typing Text
- Use `<animate>` as a child of what element is being animated with `from` and `to` with a `duration`

## Morph Text Glyphs
- Convert your text to paths with Illustrator outlines

## Self drawing text
- `stroke-dasharray` and `stroke-dashoffset` are used to “hack” this effect

# Designing Complex SVG Animations: Sarah Drasner
Twitter: [@sarah_edo](http://twitter.com/sarah_edo)

Slides: [Designing Complex SVG Animations](http://slides.com/sdrasner/cssdevconf#/)

- Why make complex animations?
  - powerful to convey meaning
  - fun :)
- Animation should be designed and not an afterthought or it will look like sugar on top animations
- One size does not fit all, look at your website and limitations
- Checkout Val Head’s “[All the Right Moves](http://valhead.com/category/all-the-right-moves-screencast/)”
- When designing complex animations try to design everything first and then apply the animations
- Ugly storyboards save you time (even if ther're ugly)!
- SVG has less HTTP requests
- Optimize your SVGs!
- But don’t overdo the amount of animations you include on your website, simplicity is key

## UI/UX Animation
- This is used to enhance the information on the page

## Context-Shifting
- This removes the breakpoints of information being loaded on the page
- Use animation to fill time while loading to keep the users mind at ease
- Provide clear focus on what the user should be reading or looking at

## Standalone
- Questions to ask
  - Responsive?
  - toggle on/off?
  - Easing structures
  - User flow
- Easing can contribute to your branding
  - You can convey emotion with how you animate elements
- Animation branding guidelines make communication down the line easy

## Animation performance
- Test everything yourself
- People expect everything to be faster on the web

## SVG sprites complex to simple
- Design your three steps for desktop, tablet, and mobile
- Combine elements where you can so you have less SVGs elements you need to hide when going between views
- Use animation media queries
- `viewBox` shift with JS
- provide fallbacks

## Complex animations
- Use JS to make this easy
- Use [Greensock](http://greensock.com/get-started-js)
- If you need more then 2-3 chained events in your animation its a good idea to use JS
- Relative color tweening
  - Example: shifting from day to night scenes
- Motion along a path is important for realism
- Responsive animations should be made with thought as you place the elements in DOM

## Design + Animation + Data
- Combining these things can bring back the success of static infographics used to have
- We can make them responsive and interactive with SVG
- Add accessibility with `<title>` tags
- Go [CodePen](http://codepen.io/)! Easy to learn new things when you can dive into other peoples code

# The Dark Arts of Light Speed: Henri Helvetica
Twitter: [@HenriHelvetica](https://twitter.com/HenriHelvetica)

- Web performance = speed
- Font-end development suffers from the embarrassment of riches
- 57% of visiters will abandon a page after 3 seconds of not loading
- User experience metrics over network-based metrics
- Need a culture based on building apps for performance
- Placing `defer` in your `<script>` tag will download JS at the same time as HTML but execute JS at the end of the HTML loading
  - async will download JS and load HTML at the same time but pause the loading of HTML when the JS download finishes to execute it
- Don’t send larger images to mobile when you don’t have to, it waists bandwidth on phones
- `<srcset>` `<picture>` you can use media queries inside them to load images for specific VW
- Reduce the number of HTTP requests with combining .css files into one and .js files into one

# No Pain No Gain: Stacy Kvernmo
Twitter: [@funstacy](https://twitter.com/funstacy)

Slides: [No Pain No Gain](http://www.slideshare.net/Funstacy/no-pain-no-gain-css-code-reviews-ftw)

- Build a culture of code review in your workplace
  - Catch bugs
  - Increase familiarity of the project with your team
  - Education! communication with your team on why you did what you did will tach you to explain things simply
- Review the compiled code when you use pre-processors
- Contributing to open source is great and try to repay the contributor somehow
- Stay positive during code reviews
- Avoid absolute terms when commenting
  - Must
  - Always
  - Never
- Ask questions about why the person coded a certain way
- Document the issues you find
- Document your code with comments
- A pull request should say what you did very clearly

## What to review
- Follow standards
- Is the code easy to understand
- Don’t need to nest everything, don’t go as far as 3-4 levels deep
- Accessibility
- Using correct vendor prefixes?

# Keynote Jina Bolton
Twitter: [@jina](https://twitter.com/jina)

Slides: [Designing a Design System](https://speakerdeck.com/jina/designing-a-design-system)

- Communication between Designers and Developers is important
- designing systems rather then pages
- style guides should be living and constantly updated
- [designprinciplesftw.com](http://designprinciplesftw.com)
- Don’t make things until you need it

## v2mom
- vision
- values
- methods
- obstacles
- measures

# Keynote Val Head
Twitter: [@vlh](https://twitter.com/vlh)

Slides: [Designing Meaningful Animation](http://www.slideshare.net/valhead/designing-meaningful-animation)

- With new tools we have the ability to make accessible responsive and beautiful animations for the web!
- Using motion in our design language is important
- When you have motion across all platforms it provides a more recognizable interface for the user
- Be subtle with movements, a little will go a long way

# CSS Architecture: Jonathan Snook
Twitter: [@snookca](https://twitter.com/snookca)

Slides: Coming soon

- Build modular systems
- INLINE STYLES WON'T SAVE YOU FROM INHERITANCE
- Don’t write multiple of the same rule for one element
- Future we can us `all: inherit` on an element to ignore all inherited styles
- Element queries can be used but you need JS to accomplish this
- Design has a cost on the web just like it does in print
- Every peace of design ends up in code
- You can use emojis as class names :P

## Categorization of styles
- state
- Theme
- module
- layout
- base

## Naming conventions
- Use them!
- [SMACSS](https://smacss.com/)
- [BEM](http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/)
- The goal is to isolate an element from everything else on the page

## Create Standards For Your CSS
- Without standards and code reviewing, CSS will get out of control
- [Styleguides.io](http://styleguides.io) is a great resource

## Future
- Web components
- Composable UIs
- Communicate!


# Bower Power! Supercharging Front-End Manageability: Eric Carlisle
Twitter: [@eric_carlisle](https://twitter.com/eric_carlisle)

Slides: [Bower Power! Supercharging Front-End Manageability](http://www.slideshare.net/ericcarlisle/bower-power-54549427)

- Keep It Stunningly Simple (KISS)
- You get a happy team
- Better products, process, reduce cost
- Don’t be afraid to use npm and bower

## Bower keeps it simple
- Maintains a dependency manifest
- Fetches them when you need it
- Tracks dependencies
- Integrates with everything

## You need
- Node.js Javascript runtime
- npm, Node.js package manager
- git, version control

## Starting the awesome
- `npm install -g bower`
- `bower init`

## Installing dependencies
- `bower install dependenciesName`
- add a `--save` after install to save that dependency for the project
- add a `--save-dev` after install to save that dependency for development or debugging
- Add `bower_components` to `.gitignore`!!

# Fight the Zombie Pattern Library: Marcelo Somers
Twitter: [@marcelosomers](https://twitter.com/marcelosomers)

Slides: [Fight the Zombie Pattern Library](https://speakerdeck.com/marcelosomers/fight-the-zombie-pattern-library-css-dev-conf-2015)

- “How do you keep building interfaces knowing thats what the world is like”
- Pattern library accelerate both the design process and development process
- Photoshop has libraries that you can make/use in multiple files/projects
  - You can do this in teams also
- Traditional handoff between designers and developers is broken
- Use pattern libraries as the connection between the groups
- Libraries eliminate waste
- This reduces tweaking static comps to make one small change but rather make one change to an item in a library
- You want an automated library or a team managing your libraries

## Get started today
- Take an inventory
- Take documentation
  - Base styles
  - Components
  - Page templates
- Focus on standardizing what you find
- Define CSS standards
  - Refactor to perfection
  - Namespace the CSS
  - Don’t forget about JavaScript applying classes
- Govern your library
- Open source culture
  - [opencss.klamp.in](http://opencss.klamp.in)

## Pattern Library Tools
- Writing CSS documentation with [KSS](http://warpspire.com/kss/)
  - will auto document comments in your `.css` file
- Pattern lab on GitHub

### The better way
- [patternpack](https://github.com/patternpack/patternpack)
  - what it does
    - Build your static site
    - Increment your version
    - Create a new commit
    - Tag the commit
  - Lets you share the code to multiple applications
  - Keeps versions of the design
  - Start new project with `npm init` and `git init`
  - Install `npm install --save-dev pattern-pack`
  - Start with `grunt patternpack run`
  - Create your first patter with a `.md` and `.css` file
    -  `.md` is the documentation for the equivalent `css` file
  - Use semantic versioning for your pattern pack
  - Publish your patternpack
    - `grunt pattern pack:release`
    - `git push —follow-tags`

# Web Components and the Future of Modular CSS: Philip Walton
Twitter: [@philwalton](https://twitter.com/philwalton)

Slides: [Web Components And the future of Modular CSS](https://philipwalton.github.io/talks/2015-10-26/#1)

- Good news is that web components were primarily a google effort but not all vendors are on board but could be available sometime in 2016
- Your selectors are the biggest determining factor in how scalable your code is

## Whats changed?
- Multiple shadow roots have gone away
- `createShadowRoot()` is now `attachShadow(mode)`

## CSS is hard
- Manage global names
- Scoping/isolating styles
- Specificity conflicts
- Unpredictable matching
- Managing styles dependencies
- Removing unused code

## What is CSS missing
- Scope or isolate styles to a particular set of DOM nodes
- Ability to abstract away implementation details
- Goooo Web components! They do this
- You don’t want to have to depend on tools that everyone has to learn
- No ecosystems

## The Anatomy of a Web Component
- Elements in a shadow DOM
  - Its a subtree of a DOM node that can’t be styled by CSS
  - Shadow nodes are private
- Custom elements
- HTMl imports
- The template element

# Keynote Dave Rupert
Twitter: [@davatron5000](https://twitter.com/davatron5000)

Slides: [The Art Of Being Wrong](https://speakerdeck.com/davatron5000/the-art-of-being-wrong)

- Woot [Shop Talk show](http://shoptalkshow.com/) plug
- Working on [godaytrip.com](http://godaytrip.com)
- Remove the must do’s and “facts” from statements online on twitter or medium
- what you think you know about dinosaurs is WRONG!
- Be afraid of the Donald Trump effect where you believe bullshit if it is said loud and long enough
- Don’t spell Sass or SASS wrong or the internet will bring the pitchforks, aka people should not fight about every little thing on the web
- You don’t have to be right all the time and you don’t have to correct people on everything all the time
