multi-file-lang [![Build Status](https://travis-ci.org/AlexKnauth/multi-file-lang.png?branch=master)](https://travis-ci.org/AlexKnauth/multi-file-lang)
===
a racket #lang for multiple files in one

documentation: http://docs.racket-lang.org/multi-file-lang/index.html

Example:
```racket
#lang multi-file
#file a.rkt
#lang racket/base
(provide x f)
(define x 3)
(define (f x) (string-append "hello" (make-string x #\!)))
(f 1)
#file b.rkt
#lang racket/base
(require "a.rkt")
x
(f x)
```
