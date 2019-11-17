#lang racket
(provide (all-defined-out))

(require "program.rkt")

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
