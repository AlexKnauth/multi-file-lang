#lang scribble/manual

@(require (for-label racket/base))

@title{multi-file-lang}

source code: @url{https://github.com/AlexKnauth/multi-file-lang}

@defmodule[multi-file #:lang]{
A @hash-lang[] language for writing multiple files as one file.

Different files are separated by @litchar{#file } followed by the file name.

For example this file:

@codeblock[#:keep-lang-line? #t]{
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
}

Would create the files a.rkt and b.rkt, and running this file would run both of them.
}

