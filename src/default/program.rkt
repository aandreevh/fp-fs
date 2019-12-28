#lang racket
(provide (all-defined-out))


(require "../core/term.rkt")
(require "../core/program.rkt")
(require "../core/fs.rkt")
(require "../core/explorer.rkt")


(define p_main (program->create "main" (lambda (term)
(define args 
(string-split (read-line) #rx"(?<!\\\\) "))
(define nterm (term->invoke term (car args) (cdr args)))
(if nterm
(term->invoke nterm "main")
(void)
)
)))



(define p_exit (program->create "exit" (lambda (term)
(begin
    (display "Bye!")
    #f
)
)))

(define p_pwd (program->create "pwd" (lambda (term)
(begin
    (display (explorer->path (term->context term)))
    (display "\n")
    term
)
)))


(define p_cd (program->create "cd" (lambda (term . args)
(define nterm term)
(begin
   (if (not (= (length args) 1))
   (display "Invalid argument count!\n")
   (let ((fd (explorer->find (term->context term) (car args))))
   (if (null? fd)
   (display "File not found!\n")
   (if (not (file->directory? fd))
   (display "Directory not a directory!\n")
    (begin
    (set! nterm ( term->create (context->move (term->context term) fd) (term->env term) ))
    (display "Moved to ")
    (display (explorer->path (term->context nterm)))
    (display "\n")
    
    )
   )
   )
   
   ))
    nterm
)
)))


(define p_touch (program->create "touch" (lambda (term . args)
(begin
    (map (lambda (name) (file->regular (context->cur (term->context term)) name "" )) args)
    term
)
)))


(define p_mkdir (program->create "mkdir" (lambda (term . args)
(begin
    (map (lambda (name) (file->directory (context->cur (term->context term)) name )) args)
    term
)
)))


(define p_ls (program->create "ls" (lambda (term . args)
(begin
    (map (lambda (file)
    (begin
    (display (file->name file))
    (display " ")
    )
    ) (file->sub (context->cur (term->context term)) (lambda x #t)))
    (display "\n")
    term
)
)))

