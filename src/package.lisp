(defpackage #:source-context
  (:use #:cl)
  (:documentation
   "Tools for building, inspecting, and rendering source-code contexts for LLMs.")
  (:export

   ;; Classes
   #:context
   #:asdf-context

   ;; Constructors
   #:make-context
   #:make-asdf-context

   ;; Context accessors
   #:context-root
   #:context-files

   ;; ASDF context accessors
   #:context-system
   #:context-system-name
   #:context-asd-file

   ;; Context modification
   #:add-file
   #:remove-file
   #:clear-context
   #:source-context

   ;; Inspection
   #:list-files
   #:list-components
   #:context-summary

   ;; Rendering
   #:render-file
   #:render-context
   #:context-string
   #:write-context

   ;; Statistics
   #:context-character-count
   #:context-token-count
   #:*characters-per-token*))

(in-package :source-context)
