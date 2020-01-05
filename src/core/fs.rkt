#lang racket
(provide (all-defined-out))

(define (file->metadata file) (car file))
(define (file->name file) (car (file->metadata file)))
(define (file->parent file) (cdr (file->metadata file)))
(define (file->content file) (cdr file))

(define (file? file [deep #f] )
  (and (pair? file)
       (pair? (file->metadata file))
       (string? (file->name file))
       (if (not deep) #t
	    (or (null? (file->parent file))
		       (file? (file->parent file))) ))) 

(define (file->check? op)
  (lambda (file [deep #f]) 
    (and (not (null? file)) (file? file deep) (op (file->content file)))))

(define file->regular? (file->check? string?))
(define file->directory? (file->check? hash?))
(define (file->root? file [deep #f]) (and (file? file deep) (null? (file->parent file))))

(define (file->contains? file data)
  (if (not (string? data)) #f
  (cond ( (file->regular? file)
	  (string-contains? (file->content file) data) )
	((file->directory? file)
	 (hash-has-key? (file->content file) data))
	 (else #f))))

(define (file->dir-get directory filename)
  (if (and (file->directory? directory) 
	   (hash-has-key? (file->content directory) filename)
	   (string? filename))
    (hash-ref (file->content directory) filename)
    '()))

(define (file->root) (cons (cons "" '()) (make-hash)))

(define (file->create parent name content) 
  (if 
    (and (file->directory? parent) (string? name) 
	 (or (string? content) (hash-empty? content)))
    (if (file->contains? parent name) 
      '()
      (begin
     (hash-set! (file->content parent) name (cons (cons name parent) content) )
     (hash-ref (file->content parent) name)))
    '()))

(define (file->regular parent name data) 
  (if (string? data) 
    (file->create parent name data) 
    '()))

(define (file->directory parent name) (file->create parent name (make-hash)))


(define (file->remove file)
  (if (file? file)
    (begin
      (hash-remove! (file->content (file->parent file)) (file->name file))
      (file->parent file)
      ) '() ))

(define (file->sub directory pred?)
  (if (not (file->directory? directory)) '()
	(filter (lambda (e) (not (null? e)))
		(hash-map (file->content directory)
		       (lambda (name file) 
			 (if (pred? file)  file
			   '())) ))))

(define (file->sub-directory directory) (file->sub directory file->directory?))
(define (file->sub-regular directory) (file->sub directory file->regular?))


