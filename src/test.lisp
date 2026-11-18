;;;; /source-context/src/classes.lisp

(in-package :source-context)

(defparameter *ctx*
    (source-context:make-context
     #p"~/quicklisp/local-projects/LLM/source-context/"))

(source-context:source-context *ctx* :regexp "\\.(lisp|asd)$")

(render-context *ctx*)

(write-context *ctx* "~/Downloads/source-context-root.txt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter *asdf-ctx*
    (make-asdf-context "source-context"))

(write-context *asdf-ctx* "~/Downloads/source-context.txt")

(render-context *asdf-ctx*)
