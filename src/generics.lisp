;;;; ./source-context/src/methods.lisp

(in-package #:source-context)

(defgeneric list-files (context &optional stream)
  (:documentation
   "Write the list of files contained in CONTEXT to STREAM."))

(defgeneric list-components (context &optional stream)
  (:documentation
   "Write the component structure of CONTEXT to STREAM."))

(defgeneric context-summary (context &optional stream)
  (:documentation
   "Write a summary of CONTEXT to STREAM."))

(defgeneric render-file (context file &optional stream)
  (:documentation
   "Write the rendered contents of FILE from CONTEXT to STREAM."))

(defgeneric render-context (context &optional stream)
  (:documentation
   "Write the rendered contents of CONTEXT to STREAM."))

(defgeneric write-context (context &optional pathname)
  (:documentation
   "Write the rendered contents of CONTEXT to PATHNAME.

When PATHNAME is omitted, write the context to ~/LLM/<name>.txt,
where <name> is derived from CONTEXT."))

(defgeneric context-name (context)
  (:documentation
   "Return the name used for CONTEXT when constructing default pathnames."))

(defgeneric make-and-write-context (class source &optional pathname)
  (:documentation
   "Create a context of CLASS from SOURCE and write it to PATHNAME.

PATHNAME may be omitted, in which case WRITE-CONTEXT determines
the default output pathname."))
