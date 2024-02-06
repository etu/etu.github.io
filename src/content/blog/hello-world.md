---
title: Hello World!
date: '2019-06-08T20:10:00+0100'
tags: [Meta]
---

Hello world! This is a test blog post.

This is an external link [example.org](https://example.org/). Internal link [start page](/).

> This is a block quote element.

This is an inline `code` block.

## Test of syntax highlighting

### elisp

```elisp
;; Define the hello function
(defun hello ()
  "This
   is my
   docstring"
  (message "world"))

;; Call the hello function
(hello)
```

### Nix

```nix
{
  # Define the hello function
  hello = {}: "world";

  # More tests
  boolean = true;
  fileimport = import ./src/file.nix;

  # Call the hello function
  message = hello {};
}
```

### Go

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello world")
}
```

### PHP

```php
<?php
# Define the hello function
function hello() : void {
    echo "world";
}

// Call the hello function
hello();
```

## Sample text

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Tempor orci dapibus
ultrices in iaculis nunc sed augue lacus. Donec ac odio tempor orci dapibus
ultrices in. Faucibus vitae aliquet nec ullamcorper sit amet risus. Pulvinar
sapien et ligula ullamcorper malesuada proin libero. Magna sit amet purus
gravida quis blandit turpis cursus in. Elit ullamcorper dignissim cras
tincidunt lobortis feugiat vivamus at augue. Ut morbi tincidunt augue
interdum. Enim ut tellus elementum sagittis vitae et. At augue eget arcu
dictum varius duis.
