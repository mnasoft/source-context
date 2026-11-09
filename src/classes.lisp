;;;; /source-context/src/classes.lisp

(in-package #:source-context)

(defclass context ()
  ((root
    :initarg :root
    :reader context-root)
   (files
    :initarg :files
    :initform nil
    :accessor context-files)
   (exclude-directories
    :initarg :exclude-directories
    :initform '(".git" "generated")
    :accessor context-exclude-directories)
   (exclude-files
    :initarg :exclude-files
    :initform nil
    :accessor context-exclude-files)))

(defclass asdf-context (context)
  ((system
    :initarg :system
    :accessor context-system)
   (system-name
    :accessor context-system-name)
   (asd-file
    :accessor context-asd-file)
   (include-asd-p
    :initarg :include-asd-p
    :initform t
    :reader context-include-asd-p)))
