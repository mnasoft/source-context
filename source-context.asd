(defsystem "source-context"
  :description "Build and inspect source contexts for LLMs."
  :version "0.1.1"
  :author "Микола"
  :license "MIT"
  :depends-on ("cl-ppcre")
  :serial t
  :components
  ((:module "src"
    :serial t
    :components
    ((:file "package")
     (:file "generics")
     (:file "classes")
     (:file "context")
     (:file "asdf-context")
     (:file "methods")))))


