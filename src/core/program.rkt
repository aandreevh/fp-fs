#lang racket
(provide (all-defined-out))

(define (program->name program)
  (car program))

(define (program->func program)
  (cdr program))

(define (program->create name func)
  (cons name func))
