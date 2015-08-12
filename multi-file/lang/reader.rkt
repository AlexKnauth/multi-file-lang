#lang racket/base

(provide read read-syntax)

(require racket/match
         racket/list
         racket/string
         )
(module+ test
  (require rackunit))

(define (read in p ln col pos)
  (syntax->datum (read-syntax #f in p ln col pos)))

(define (read-syntax src in p ln col pos)
  (define lines
    (for/list ([line (in-lines in)])
      line))
  (define grouped
    (group-lines lines))
  (define files-alist
    (for/list ([group (in-list grouped)])
      (match-define (cons name lines) group)
      (cons name (string-join lines "\n" #:after-last "\n"))))
  (for ([p (in-list files-alist)])
    (match-define (cons name text) p)
    (call-with-output-file* name #:exists 'replace
      (λ (out)
        (display text out))))
  (datum->syntax #f
    `(module _ racket/base
       ,@(append*
          (for/list ([p (in-list files-alist)])
            (match-define (cons name _) p)
            (list
             `(printf "#file ~a\n" ',name)
             `(dynamic-require ',name #f)))))))

;; file-decl-line?
(module+ test
  (check-equal? (file-decl-line? "#file a.rkt") "a.rkt")
  (check-equal? (file-decl-line? "#filea.rkt") #f)
  (check-equal? (file-decl-line? "") #f))

(define (file-decl-line? line)
  (define len6 (string-length "#file "))
  (and (<= len6 (string-length line))
       (string=? (substring line 0 len6) "#file ")
       (substring line len6)))

;; group-lines
(module+ test
  (check-equal? (group-lines (list "#file a.rkt"
                                   "first line"
                                   "second line"
                                   "#file b.rkt"
                                   "first line of b"
                                   "and the second"
                                   "#file c.rkt"))
                (list (list "a.rkt"
                            "first line"
                            "second line")
                      (list "b.rkt"
                            "first line of b"
                            "and the second")
                      (list "c.rkt"))))

(define (group-lines lines)
  (let loop ([rev-group '()] [rev-grouped '()] [lines lines])
    (match lines
      ['() (cdr (reverse (cons (reverse rev-group) rev-grouped)))]
      [(cons fst rst)
       (define file (file-decl-line? fst))
       (cond [file
              (loop (list file) (cons (reverse rev-group) rev-grouped) rst)]
             [else
              (loop (cons fst rev-group) rev-grouped rst)])])))


