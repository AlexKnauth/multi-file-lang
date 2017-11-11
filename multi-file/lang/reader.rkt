#lang racket/base

(provide read read-syntax)

(require racket/match
         racket/string)
(module+ test
  (require rackunit))

;; An [AssocMapping X Y] is a [Listof [Pair X Y]]
;; interpretation
;;   A mapping from Xs to Ys, where each X is associated with the Y in its
;;   pair. For example in (list (cons 'a 1) (cons 'b 2)), 'a maps to 1 and
;;   'b maps to 2.

;; read : InputPort PosInt Nat PosInt -> ModuleSExpr
(define (read in p ln col pos)
  (syntax->datum (read-syntax #f in p ln col pos)))

;; read-syntax : Any InputPort Any PosInt Nat PosInt -> ModuleSyntax
(define (read-syntax src in p ln col pos)
  ;; lines : [Listof StxString]
  (define lines
    (read-syntax-lines in src ln col pos))
  (datum->syntax #f
    `(module _ multi-file/lang
       
       (multi-file
        ,@(for/list ([group (in-list (group-lines lines))])
            (match-define (cons name contents) group)
            `[,name
              ,(string-join (map syntax-e contents) "\n" #:after-last "\n")])))
    (list src ln col pos 0)))

;; read-syntax-lines : InputPort Any PosInt Nat PosInt -> [Listof StxString]
(define (read-syntax-lines in src ln col pos)
  (let loop ([line (read-line in)] [ln ln] [col col] [pos pos] [acc '()])
    (cond
      [(eof-object? line) (reverse acc)]
      [else
       (define-values [ln* col* pos*] (port-next-location in))
       (loop (read-line in) ln* col* pos*
             (cons
              (datum->syntax #f
                             line
                             (list src ln col pos (max 0 (- pos* pos))))
              acc))])))

;; file-decl-line? : StxString -> [Maybe StxString]
(module+ test
  (check-equal? (syntax-e (file-decl-line? #'"#file a.rkt")) "a.rkt")
  (check-equal? (file-decl-line? #'"#filea.rkt") #f)
  (check-equal? (file-decl-line? #'"") #f))

(define (file-decl-line? line)
  (define s (syntax-e line))
  (define len6 (string-length "#file "))
  (and (<= len6 (string-length s))
       (string=? (substring s 0 len6) "#file ")
       (datum->syntax
        line
        (substring s len6)
        (list (syntax-source line)
              (syntax-line line)
              (and (syntax-column line)
                   (+ (syntax-column line) len6))
              (and (syntax-position line)
                   (+ (syntax-position line) len6))
              (and (syntax-span line)
                   (max 0 (- (syntax-span line) len6)))))))

;; group-lines :
;; [Listof StringSyntax] -> [AssocMapping StringSyntax [Listof String]]
(module+ test
  (check-equal? (map
                 (λ (x) (map syntax-e x))
                 (group-lines (list #'"#file a.rkt"
                                    #'"first line"
                                    #'"second line"
                                    #'"#file b.rkt"
                                    #'"first line of b"
                                    #'"and the second"
                                    #'"#file c.rkt")))
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


