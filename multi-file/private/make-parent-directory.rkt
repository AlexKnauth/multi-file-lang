#lang racket/base

(provide make-parent-directory*)

(define make-parent-directory*
  (dynamic-require
   'racket/file
   'make-parent-directory*
   (λ ()
     (dynamic-require 'multi-file/private/fallback-make-parent-directory
                      'fallback-make-parent-directory*))))

