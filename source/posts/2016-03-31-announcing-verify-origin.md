---
layout: post
title: "Announcing VerifyOrigin"
comments: true
author: Dan McClain
twitter: "\_danmcclain"
github: danmcclain
social: true
summary: "Securing your API without a CSRF token"
published: true
tags: phoenix, security
---

In web applications, if you are using cookies for storing authentication
state, you should be worrying about [Cross Site Request Forgery][csrf]
(CSRF). In short, when using cookies, other sites can create an HTML
form that submits to your backend. When your browser submits that form,
it will attach any cookies it has that are associated with the URL that
the form is submitted to. Without any steps taken to mitigate this, a
malicious third party could create a form on their site that performs an
action on application, maybe as harmless as following them on a site, or
as malicious as deleting your account or transferring funds. [OWASP has
more details on CSRF attacks as well][owasp-csrf].

## Typical CSRF prevention

The way that most applications mitigate CSRF attacks is by utilizing a
synchronizer CSRF token that is stored in a hidden HTML input in the
form which matches a token in the current user's session. In short,
malicious forms will be lacking this token and will be rejected. [More
details on token based mitigation are covered in this
OWASP page][owasp-csrf-mitigation].

## What about Single Page applications? Is a JSON only API vulnerable?

CSRF tokens work well for server side rendered applications (SSR), since
the HTML generated on the server can securely include the token that is in the
session cookie. But what about single page application like Ember? Can
you craft an HTML form to submit a valid request to a JSON based API?
The answer is [yes it is possible][csrf-vs-json].

Ok, so how can we secure this API backend without a CSRF token?

### Enter Referer/Origin header verification

With the exception of `GET` requests, when your browser submits a
request, it attaches both a `Referer` (that typo is historical) and
`Origin` header. The `Origin` header is a bit newer, it was originally
introduced for Cross Origin Resource Sharing (CORS), but has been
repurposed for CSRF mitigation as well. We can use the `Referer` or
`Origin` header to verify that the request originated from the domain we
expect. In this case, I prefer the `Origin` header. When a request
originates at an HTTPS page and is made against an HTTP page, the
`Referer` header is dropped, while the `Origin` header will continue to
be sent. Both [OWASP][owasp-origin] and [Mozilla][mozilla-origin] talk
about the validity of using the `Origin` header as a way to mitigate
CSRF attacks.

## Places where CSRF prevention fails

No matter how good your CSRF prevention is, there are other vectors that
will open your application to malicious requests. If your session cookie
is not `HTTPOnly` ([details][httponly]), and/or you accidentally allow malicious JavaScript to
execute on your site, you have a couple of problems. When not using
`HTTPOnly` cookies, your cookies can be retrieved via JavaScript, and if
you have malicious JavaScript on your site, someone could siphon off all
your session cookies. At that point, this third party could forge any
header it needs to, and then include the session cookie to automate requests
against your server, so it could bypass the `Origin` check. They could
also replace the cookie in their browser with another person's cookie
that they stole, and use your site as that user, bypassing CSRF Tokens.
If your cookie is marked as `HTTPOnly`, they can still use malicious
JavaScript via a [Cross Site Scripting][xss] (XSS) attack, since any users'
browser that executes this malicious JavaScript will make the request
with either the necessary CSRF token or `Origin` header.

## Ok, so why all this information about CSRF mitigation?

At DockYard, we produce Ember applications for our clients. Since Ember
is a single page application, `Origin` header checking is the best way
we can protect any backends we produce. To the end, I recently published
[VerifyOrigin][verify-origin] to
[hex.pm](https://hex.pm/packages/verify_origin). VerifyOrigin
provides a `Plug` you can add to your applications pipeline to only
allow requests from `Origin`s you expect:

```elixir
plug VerifyOrigin, ["https://example.com"]
```

The plug expects a list of valid `Origin` URLs. If the request does not
have an `Origin` header that matches your list, then it returns a `400
Bad Request` response to the client. Simple CSRF mitigation for your
Phoenix app is at your fingertips!

A special thanks to [Craig Ingram][cji], who I consulted with multiple
times when coming up with this plug!

[csrf]: https://en.wikipedia.org/wiki/Cross-site_request_forgery
[owasp-csrf]: https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)
[owasp-csrf-mitigation]: https://www.owasp.org/index.php/CSRF_Prevention_Cheat_Sheet#General_Recommendation:_Synchronizer_Token_Pattern
[csrf-vs-json]: https://www.gracefulsecurity.com/csrf-vs-json/
[owasp-origin]: https://www.owasp.org/index.php/CSRF_Prevention_Cheat_Sheet#CSRF_Prevention_without_a_Synchronizer_Token
[mozilla-origin]: https://wiki.mozilla.org/Security/Origin
[httponly]: https://www.owasp.org/index.php/HTTPOnly
[xss]: https://en.wikipedia.org/wiki/Cross-site_scripting
[verify-origin]: https://github.com/danmcclain/verify_origin
[cji]: https://twitter.com/cji
