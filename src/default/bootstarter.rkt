#lang racket
(provide (all-defined-out))


(require "../core/term.rkt")
(require "../core/explorer.rkt")
(require "../core/fs.rkt")
(require "env.rkt")

(define (bootstart)
(define def-term (term->create (context->create (file->root)) def-env ))
(term->invoke def-term "main")
)