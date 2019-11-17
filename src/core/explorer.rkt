#lang racket
(provide (all-defined-out))
(require "fs.rkt")

;(fs-root ; current)
(define (context->create fs)
  (cons fs fs))

(define (context->root cntx)
  (car cntx))

(define (context->move cntx file)
  (cons (context->root cntx) file))

(define (context->cur cntx)
  (cdr cntx))

(define (explorer->path-resolver path)
  (string-split path "/"))

(define (explorer->root-path? path)
  (string-prefix? path "/"))

(define (explorer->find context path)
  
(define managed-path (explorer->path-resolver path))

  (define (helper cur mp)
      (cond 
      ((null? mp) cur)
      ((equal? (car mp) "..") (helper (file->parent cur) (cdr mp)))
      ((or (equal? (car mp) ".") (equal? (car mp) "")) (helper cur (cdr mp)))
      ((not (file->directory? cur)) '())
	    (else (helper (file->dir-get cur (car mp)) (cdr mp)) )))

  (if (explorer->root-path? path)
    (helper (context->root context) managed-path)
    (helper (context->cur context) managed-path)))


