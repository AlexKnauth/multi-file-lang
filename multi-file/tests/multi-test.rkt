#lang multi-file
#file a.rkt
#lang typed/racket/base
(provide x f)
(: x : Natural)
(define x 3)
(: f : (Natural -> String))
(define (f x) (string-append "hello" (make-string x #\!)))
(f 1)
#file b.rkt
#lang racket/base
(require racket/contract/base "a.rkt")
x
(f x)
(value-contract f)
#file c.txt
I'm not code, I'm just text in a text file.
#file d.rkt
#lang racket/base
(read-line (open-input-file "c.txt"))
