#lang racket
(provide (all-defined-out))
(require "fs.rkt")


;(fs-root ; current)
(define (context->create fs (cur fs))
  (cons fs cur))

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

(define (explorer->basename path)
 (define pths (explorer->path-resolver path))
 (if (null? pths) "" (last pths)) 
)

(define (explorer->basedir path)
 (if (string-contains? path "/")
 (string-replace path #rx"/[^/]*$" "/")
 ""
 )
)
(define (explorer->find context path)

  (define managed-path (explorer->path-resolver path))

    (define (helper cur mp)
      (cond 
      ((or (null? mp) (null? cur)) cur)
      ((equal? (car mp) "..") (helper (file->parent cur) (cdr mp)))
      ((or (equal? (car mp) ".") (equal? (car mp) "")) (helper cur (cdr mp)))
      ((not (file->directory? cur)) '())
	    (else (helper (file->dir-get cur (car mp)) (cdr mp)) )))

  (if (explorer->root-path? path)
    (helper (context->root context) managed-path)
    (helper (context->cur context) managed-path)))


(define (explorer->path context) 
  (if (eq? (context->root context) 
           (context->cur context))
    (file->name (context->root context))
    (string-append (explorer->path 
                       (context->create 
                          (context->root context) 
                          (file->parent 
                            (context->cur context)))) 
                            "/" 
                            (file->name (context->cur context)) )))

(define (explorer->find-or-create context fpath data)
  (define found (explorer->find context fpath))
  (define name (explorer->basename fpath))
  (define dir (explorer->find context (explorer->basedir fpath)))
  
  (if (null? found)
    (if (or (null? dir) (file->regular? dir))
      #f
     (begin
     (file->regular dir name data)
     #t
     )
     )
    (if (file->regular found)
      (begin
        (string-set! (file->content found) data)
        #t)
    #f)))