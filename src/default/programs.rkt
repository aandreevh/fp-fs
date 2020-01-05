#lang racket
(provide build-default-environment)

(require "../core/program.rkt")
(require "../core/explorer.rkt")
(require "../core/fs.rkt")
(require "../core/env.rkt")

(define (test . args)
    (if (null? args) 
        (void)
        (begin
            (display (car args))
            (apply test (cdr args))
            0
        )))

(define (build-default-environment) 
    (env->build
    (list
    (program->create "test" test)
    )))