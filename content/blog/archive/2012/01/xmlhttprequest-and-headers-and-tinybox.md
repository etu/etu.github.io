---
title: 'XMLHttpRequest… and headers… (and TinyBox)'
date: '2012-01-12T12:00:00+0100'
url: /index.php/2012/01/xmlhttprequest-and-headers-and-tinybox/
draft: true
---

Some call it AJAX, some call it XMLHttpRequest and others XHR, AJAX is not the common usecase of AJAX. Most people transfer JSON and not XML, or some other crap, that’s up to you as a developer.

Common practice for the two major Javascript frameworks ([jQuery](http://jquery.com/ "jQuery") and [Mootools](http://mootools.net/ "MooTools")) is to send this custom HTTP-Header: *X-Requested-With: XMLHttpRequest*

It does not break the HTTP Protocol nor the website, if the website doesnt care about the header, nothing happens. If the website requires the header to be sent to work and the javascript doesn’t send it, the website will break.

at work, we have this setup:

```php
<?php
if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) AND strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest') {
// Print response of request encoded as json
} else {
// Print template and push the data to the templatefile to render
}
```

And then we had an old setup of pages, that was using [TinyBox](http://www.scriptiny.com/2009/05/javascript-popup-box/ "TinyBox"), and got XML sent to it. And since I rebuilt the default template for that system… and implemented in the templating system to NOT RENDER the menu’s on AJAX calls… And I thought… Well, that’s it, now it will work everywhere where AJAX is used. I was wrong.

Since it’s not part of the standard XMLHttpRequest to send this header, it’s only the common practice, this header isn’t defined automagicly by the browser. Both jQuery and Mootools does this. [TinyBox](http://www.scriptiny.com/2009/05/javascript-popup-box/ "TinyBox") does not.

I thought most JavaScript developers who built libs and such things was following common practice, at least for libs people heard about. TinyBox is quite known. So I patched TinyBox:

```
diff -r 2216c184eed3 tinybox.js
--- a/tinybox.js	Thu Jan 12 17:09:54 2012 +0100
+++ b/tinybox.js	Thu Jan 12 17:11:24 2012 +0100
@@ -30,7 +30,9 @@
 				x.onreadystatechange=function(){
 					if(x.readyState==4&&x.status==200){TINY.box.psh(x.responseText,w,h,a)}
 				};
-				x.open('GET',c,1); x.send(null)
+				x.open('GET',c,1);
+				x.setRequestHeader('X_REQUESTED_WITH', 'XMLHttpRequest');
+				x.send(null)
 			}else{
 				this.psh(c,w,h,a)
 			}
```

Now my code works, and all other code on the page. So simple. Please follow common practice…
