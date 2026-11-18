;;;; /source-context/src/classes.lisp

(in-package #:source-context)

(defclass context ()
  ((root
    :initarg :root
    :reader context-root
    :documentation
    "The root directory used to resolve relative file names.")
   (files
    :initarg :files
    :initform nil
    :accessor context-files
    :documentation
    "The list of pathnames included in the context.")
   (exclude-directories
    :initarg :exclude-directories
    :initform '(".git" "generated")
    :accessor context-exclude-directories
    :documentation
    "Directory names excluded when collecting files recursively.")
   (exclude-files
    :initarg :exclude-files
    :initform nil
    :accessor context-exclude-files
    :documentation
    "Regular expressions used to exclude files from the context."))
  (:documentation
   "A collection of source files rooted at a common directory.

CONTEXT stores the files selected for inclusion and provides the base
representation used for listing, summarizing, and rendering source
content.

Files may be added, removed, or collected recursively after the context
has been created."))


(defclass asdf-context (context)
  ((system
    :initarg :system
    :accessor context-system
    :documentation
    "The ASDF system represented by this context.")

   (system-name
    :accessor context-system-name
    :documentation
    "The canonical name of the ASDF system.")

   (asd-file
    :accessor context-asd-file
    :documentation
    "The pathname of the ASDF system definition file.")

   (include-asd-p
    :initarg :include-asd-p
    :initform t
    :reader context-include-asd-p
    :documentation
    "Whether the ASDF system definition file is included in the context."))
  (:documentation
   "A source context representing the files of an ASDF system.

The set of source files is collected from the ASDF component tree when
the context is created.  Therefore, create a new ASDF-CONTEXT after
changing the system definition or its component structure.

Changes to the contents of already collected source files do not require
creating a new context, because their contents are read when the context
is rendered."))
