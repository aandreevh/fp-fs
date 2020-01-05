#lang racket
(provide (all-defined-out))

(require "../core/env.rkt")
(require "program.rkt")

(define def-env 
(let ((def-env (env->create))) (begin
(env->add  def-env p_main)
(env->add  def-env p_exit)
(env->add  def-env p_pwd)
(env->add  def-env p_cd)
(env->add  def-env p_touch)
(env->add  def-env p_mkdir)
(env->add  def-env p_ls)
(env->add def-env p_rm)
(env->add def-env p_cat)
def-env
)))