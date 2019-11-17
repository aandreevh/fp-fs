#lang racket

(provide (all-defined-out))

(require "env.rkt")
(require "fs.rkt")

(define (term->context term) (car term))
(define (term->env term) (cdr term))

(define (term->create fs-context env)
  (cons fs-context env))

(define (term->bind term program)
  (env->add (term->env term) program))

(define (term->invoke term name . args)
  (apply (env->get name) term args))

