(defsystem "source-context"
  :description "Build and inspect source contexts for LLMs."
  :version "0.1.1"
  :author "Микола"
  :license "MIT"
  :depends-on ("cl-ppcre")
  :serial t
  :components
  ((:file "src/package")
   (:file "src/context")
   (:file "src/asdf-context")))
