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

(defgeneric write-context (context pathname)
  (:documentation
   "Write the rendered contents of CONTEXT to the text file designated by PATHNAME.
The output is suitable for passing the collected source context to an LLM."))
