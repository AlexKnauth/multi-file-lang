#lang racket/base

(provide fallback-make-parent-directory*)

(require racket/file)

(define (fallback-make-parent-directory* p)
  (unless (path-string? p)
    (raise-argument-error 'make-parent-directory* "path-string?" p))
  (define-values (base name dir?) (split-path p))
  (cond
   [(path? base) (make-directory* base)]
   [else
    ;; Do nothing with an immediately relative path or a root directory
    (void)]))

