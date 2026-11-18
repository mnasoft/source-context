;;;; /source-context/src/classes.lisp

(in-package :source-context)

(defparameter *ctx*
    (source-context:make-context
     #p"~/quicklisp/local-projects/LLM/source-context/"))

(source-context:source-context
   *ctx*
   :regexp "\\.(lisp|asd)$")

(render-context *ctx*)

(in-package :source-context)

(defparameter *asdf-ctx*
    (make-asdf-context "source-context"))

(render-context *asdf-ctx*)

(write-context *asdf-ctx* "~/Downloads/1234.txt")
