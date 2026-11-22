(in-package #:source-context)


(defun git-repository-root (pathname)
  "Return the root directory of the Git repository containing PATHNAME."
  (let* ((pathname (truename pathname))
         (directory
           (if (uiop:directory-pathname-p pathname)
               pathname
               (uiop:pathname-directory-pathname pathname)))
         (output
           (uiop:run-program
            '("git" "rev-parse" "--show-toplevel")
            :directory directory
            :output :string)))
    (uiop:ensure-directory-pathname
     (truename (string-trim '(#\Space #\Tab #\Newline #\Return)
                            output)))))


(defun collect-git-files (root)
  "Return pathnames of files tracked by the Git repository at ROOT."
  (mapcar (lambda (name)
            (merge-pathnames name root))
          (uiop:run-program
           '("git" "ls-files")
           :directory root
           :output :lines)))


(defun make-git-context (pathname)
  "Create a Git context for the repository containing PATHNAME.

PATHNAME may designate either the repository root or any file or directory
inside its working tree."
  (make-instance 'git-context
                 :root (git-repository-root pathname)))


(defmethod initialize-instance :after ((context git-context) &key)
  (setf (context-files context)
        (collect-git-files (context-root context))))
