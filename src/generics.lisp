;;;; ./source-context/src/methods.lisp

(in-package #:source-context)

(defgeneric list-files      (context &optional stream))
(defgeneric list-components (context &optional stream))
(defgeneric context-summary (context &optional stream))
(defgeneric render-file     (context file &optional stream))
(defgeneric render-context  (context &optional stream))
