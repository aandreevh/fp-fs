#lang racket
(provide (all-defined-out))


(require "../core/term.rkt")
(require "../core/program.rkt")
(require "../core/fs.rkt")
(require "../core/explorer.rkt")
(require "../core/env.rkt")



(define p_main (program->create "main" (lambda (term)
(define args 
  (map (lambda (x) 
               (string-replace x "\\ " " ") )
                (string-split (read-line) #rx"(?<!\\\\) ")))
  
  (if (null? args)
      (term->invoke term "main")
  (if (env->contains? (term->env term) (car args))
    (let (( nterm (term->invoke term (car args) (cdr args))))
      (if nterm
        (term->invoke nterm "main")
        term
      ))
  (begin
    (display "Invalid command! For more information type command: help.\n")
    (term->invoke term "main"))
  
  )))))



(define p_exit (program->create "exit" (lambda (term)
#f
)))

(define p_pwd (program->create "pwd" (lambda (term)
(begin
    (define pth (explorer->path (term->context term)))
    (if (eqv? pth "")
     (display "/")
     (display pth)
     )
    (display "\n")
    term
))))


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
                 (let ((pth (explorer->path (term->context nterm))))
                (if (equal? pth "")
                (display "/")
                (display pth)))
                (display "\n")
    
    )))))
    nterm
))))


(define p_touch (program->create "touch" (lambda (term . args)
(begin
    (map 
      (lambda (fullpath)
        (let* ((name (explorer->basename fullpath))
               (dir (explorer->basedir fullpath))
               (ddir (explorer->find (term->context term ) dir)))
                  (if (and (file->directory? ddir) 
                      (not (file->contains? ddir name)))
                        (file->regular ddir name "")
                          (begin
                          (display "Could not create file with name ")
                          (display name)
                          (display "!\n"))
    ))) args)
    term
))))


(define p_mkdir (program->create "mkdir" (lambda (term . args)
(begin
    (map 
      (lambda (fullpath)
        (let* ((name (explorer->basename fullpath))
               (dir (explorer->basedir fullpath))
               (ddir (explorer->find (term->context term ) dir)))
                  (if (and (file->directory? ddir) 
                      (not (file->contains? ddir name)))
                        (file->directory ddir name)
                          (begin
                          (display "Could not create file with name ")
                          (display name)
                          (display "!\n"))
    ))) args)
    term
))))

(define p_rm (program->create "rm" (lambda (term . args)
(begin
    (map 
      (lambda (fullpath)
        (let* ((fl (explorer->find (term->context term ) fullpath)))
                  (if (not (null? fl))
                        (file->remove fl)
                          (begin
                          (display "Could not remove file with name ")
                          (display (explorer->basename fullpath))
                          (display "!\n"))
    ))) args)
    term
))))

(define p_ls (program->create "ls" (lambda (term . args)
(begin
(define cur-dir (if (null? args) 
                  (context->cur 
                    (term->context term))
                  (explorer->find
                   (term->context term)
                   (car args) )))
  (if (file->directory? cur-dir)
    (map (lambda (file)
           (begin
            (display "'")
            (display (file->name file))
            (display "'")
            
             (display " ")
           )) 
      (file->sub 
        cur-dir 
        (lambda x #t)))
        (display "Not a directory!"))
    (display "\n")
    term
))))

(define p_cat (program->create "cat" (lambda (term . args)
(define files_read (takef args (lambda (x) (not (equal? x ">"))) ))
(define files_write (cdr (dropf args (lambda (x) (not (equal? x ">"))))))
 
(define (read-helper)
(define ln (read-line))
  (if (equal? ln ".")
    ""
    (string-append ln "\n" (read-helper))))
 
(define in (if (null? files_read) 
               (string-replace 
                 (read-helper) #rx"\n$" "") 
                 (void)))
  (begin
  (if (null? files_write)
  (display in)
  (void)
  )
  term))))