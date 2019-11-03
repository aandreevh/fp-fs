#lang racket
(require "fs.rkt")
(require "term.rkt")

(define fs (file->root))
(define f1 (file->regular fs "f1" "data"))
(define d1 (file->directory fs "1"))
(define d2 (file->directory d1 "2"))
(define d3 (file->directory d2 "3"))
(define d4 (file->directory d3 "4"))
(define d5 (file->directory d2 "5"))
(define f2 (file->regular d5 "f2" "lala"))

(file->content (explorer->find (cons fs d2) "/1/2/5/f2"))

(define env (env->create))
(define test-program (lambda () (display "test")))
(env->add env (program->create "test" test-program))

env
