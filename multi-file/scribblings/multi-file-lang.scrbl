#lang scribble/manual

@(require (for-label racket/base lang-file/read-lang-file))

@title{multi-file-lang}

source code: @url{https://github.com/AlexKnauth/multi-file-lang}

@defmodule[multi-file #:lang]{
A @hash-lang[] language for writing multiple files as one file.

Different files are separated by @litchar{#file } followed by the file name.
Each file is created with a path relative to the multi-file source file.

If a sub-file is not a @hash-lang[] file (according to @racket[lang-file?]),
@racketmodname[multi-file] does not run it, but it is still created so that
other files can read from it.

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

Would create the files @litchar{a.rkt} and @litchar{b.rkt} in the same
directory as this file, and running this file would run both of them.

And this file:

@codeblock[#:keep-lang-line? #t]{
#lang multi-file
#file a.rkt
#lang racket/base
(read-line (open-input-file "data/text.txt"))
#file data/text.txt
I'm not code, I'm just text in a text file.
}

Would create the file @litchar{a.rkt} in the same directory as this file,
and the file @litchar{data/text.txt} relative to this file. Running this
file would only run @litchar{a.rkt} because @litchar{data/text.txt} is not
a @hash-lang[] file or a @racket[module] file.

}

