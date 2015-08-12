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
