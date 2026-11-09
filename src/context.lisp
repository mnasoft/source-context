(in-package #:source-context)

(defun make-context (root &key (exclude-directories '(".git" "generated")) exclude-files)
  (make-instance 'context :root (uiop:ensure-directory-pathname (truename root))
                          :exclude-directories exclude-directories :exclude-files exclude-files))

(defun relative-namestring (context pathname)
  (enough-namestring pathname (context-root context)))

(defun excluded-directory-p (context pathname)
  (member (car (last (pathname-directory pathname)))
          (context-exclude-directories context) :test #'string=))

(defun excluded-file-p (context pathname)
  (let ((name (relative-namestring context pathname)))
    (some (lambda (regexp) (cl-ppcre:scan regexp name))
          (context-exclude-files context))))

(defun add-file (context pathname)
  (let ((file (truename pathname)))
    (unless (or (excluded-file-p context file)
                (member file (context-files context) :test #'uiop:pathname-equal))
      (setf (context-files context) (append (context-files context) (list file)))))
  context)

(defun remove-file (context pathname)
  (let ((pathname (pathname pathname)))
    (setf (context-files context)
          (remove pathname (context-files context) :test #'uiop:pathname-equal)))
  context)

(defun clear-context (context)
  (setf (context-files context) nil)
  context)

(defun source-context (context &key (regexp ".*"))
  (labels ((walk (directory)
             (dolist (file (uiop:directory-files directory))
               (when (and (cl-ppcre:scan regexp (relative-namestring context file))
                          (not (excluded-file-p context file)))
                 (add-file context file)))
             (dolist (subdir (uiop:subdirectories directory))
               (unless (excluded-directory-p context subdir)
                 (walk subdir)))))
    (walk (context-root context)))
  context)

(defun file-size (pathname)
  (with-open-file (stream pathname :direction :input :element-type '(unsigned-byte 8))
    (file-length stream)))

(defun context-size (context)
  (loop for file in (context-files context) sum (file-size file)))

(defparameter *characters-per-token* 4.0
  "Approximate number of characters per token.")

(defun file-character-count (pathname)
  (with-open-file (stream pathname
                          :direction :input
                          :external-format :utf-8)
    (loop for character = (read-char stream nil nil)
          while character
          count 1)))

(defun context-character-count (context)
  (loop for file in (context-files context)
        sum (file-character-count file)))

(defun context-token-count (context)
  (ceiling (/ (context-character-count context)
              *characters-per-token*)))

(defun format-byte-count (count)
  (cond ((>= count (* 1024 1024)) (format nil "~,2F MiB" (/ count 1024.0 1024.0)))
        ((>= count 1024) (format nil "~,2F KiB" (/ count 1024.0)))
        (t (format nil "~D bytes" count))))

(defun context-string (context)
  (with-output-to-string (stream) (render-context context stream)))

(defun write-context (context pathname)
  (with-open-file (stream pathname :direction :output :if-exists :supersede
                                  :if-does-not-exist :create :external-format :utf-8)
    (render-context context stream))
  pathname)
