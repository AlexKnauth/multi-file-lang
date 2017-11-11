#lang racket/base

(provide #%module-begin
         multi-file)

(require syntax/parse/define
         (only-in lang-file/read-lang-file lang-file?)
         (for-syntax racket/base
                     syntax/path-spec))

(define-simple-macro (multi-file [name:str contents:str] ...)
  #:with [path-name ...] (generate-temporaries #'[name ...])
  #:with [path-expr ...]
  (for/list ([name (in-list (attribute name))])
    #`(string->path '#,(path->string (resolve-path-spec name name name))))
  (begin
    (define path-name path-expr)
    ...
    (write-file 'name path-name 'contents)
    ...
    (maybe-run-file 'name path-name)
    ...))

;; write-file : String Path String -> Void
(define (write-file name path contents)
  (call-with-output-file* path #:exists 'replace
    (λ (out)
      (void (write-string contents out)))))

;; maybe-run-file : String Path -> Void
(define (maybe-run-file name path)
  (cond [(lang-file? path)
         (printf "#file ~a\n" name)
         (dynamic-require path #f)]
        [else
         (eprintf "#file ~a is not a #lang file\n" name)]))

