#lang racket

(provide (all-defined-out))

(require "fs.rkt")

(define (program->name program)
  (car program))

(define (program->func program)
  (cdr program))

(define (program->create name func)
  (cons name func))


(define (env->create) (make-hash))

(define (env->contains? env name)
	(hash-has-key? env name))

(define (env->add env program)
  (if (env->contains? env (program->name program))
    '()
    (begin
      (hash-set! env (program->name program) program)
      env)))


(define (env->get env name) (hash-ref env name))

(define (term->context term) (car term))
(define (term->env term) (cdr term))

(define (term->create fs-context env)
  (cons fs-context env))

(define (term->bind term program)
  (env->add (term->env term) program))

(define (term->invoke term name . args)
  (apply (env->get name) term args))

