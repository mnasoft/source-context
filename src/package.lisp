(in-package #:cl-user)

(defpackage #:source-context
  (:use #:cl)
  (:nicknames "SC")
  (:documentation
   "Tools for building, inspecting, and rendering source-code contexts for LLMs.")
  (:export
   ;; Classes
   #:context
   #:asdf-context
   #:git-context

   ;; Constructors
   #:make-context
   #:make-asdf-context
   #:make-git-context
   #:make-and-write-context

   ;; Context accessors
   #:context-root
   #:context-files
   #:context-exclude-directories
   #:context-exclude-files

   ;; ASDF context accessors
   #:context-system
   #:context-system-name
   #:context-asd-file
   #:context-include-asd-p

   ;; Context modification
   #:add-file
   #:remove-file
   #:clear-context
   #:source-context

   ;; Inspection
   #:list-files
   #:list-components
   #:context-summary
   #:context-name   

   ;; Rendering
   #:render-file
   #:render-context
   #:context-string
   #:write-context

   ;; Statistics
   #:context-size
   #:context-character-count
   #:context-token-count
   #:*characters-per-token*))

(in-package #:source-context)


