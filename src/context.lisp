(in-package #:source-context)

(defclass context ()
  ((root :initarg :root :reader context-root)
   (files :initarg :files :initform nil :accessor context-files)
   (exclude-directories :initarg :exclude-directories :initform '(".git" "generated") :accessor context-exclude-directories)
   (exclude-files :initarg :exclude-files :initform nil :accessor context-exclude-files)))

(defmethod print-object ((context context) stream)
  (print-unreadable-object (context stream :type t :identity t)
    (format stream
            "~A files: ~D size: ~A"
            (context-root context)
            (length (context-files context))
            (format-byte-count
             (context-size context)))))

(defgeneric list-files (context &optional stream))
(defgeneric list-components (context &optional stream))
(defgeneric context-summary (context &optional stream))
(defgeneric render-file (context file &optional stream))
(defgeneric render-context (context &optional stream))

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

(defmethod list-files ((context context) &optional (stream *standard-output*))
  (loop for file in (context-files context) for index from 1
        do (format stream "~3D  ~A~%" index (relative-namestring context file)))
  (values))

(defmethod list-components ((context context) &optional (stream *standard-output*))
  (list-files context stream))

(defun file-size (pathname)
  (with-open-file (stream pathname :direction :input :element-type '(unsigned-byte 8))
    (file-length stream)))

(defun context-size (context)
  (loop for file in (context-files context) sum (file-size file)))

(defun format-byte-count (count)
  (cond ((>= count (* 1024 1024)) (format nil "~,2F MiB" (/ count 1024.0 1024.0)))
        ((>= count 1024) (format nil "~,2F KiB" (/ count 1024.0)))
        (t (format nil "~D bytes" count))))

(defmethod context-summary ((context context) &optional (stream *standard-output*))
  (format stream "Context~%Root:  ~A~%Files: ~D~%Size:  ~A~%"
          (context-root context) (length (context-files context))
          (format-byte-count (context-size context)))
  (values))

(defmethod render-file ((context context) file &optional (stream *standard-output*))
  (format stream "~%======================================================================~%FILE: ~A~%======================================================================~%~%"
          (relative-namestring context file))
  (with-open-file (input file :direction :input :external-format :utf-8)
    (uiop:copy-stream-to-stream input stream))
  (terpri stream)
  (values))

(defmethod render-context ((context context) &optional (stream *standard-output*))
  (dolist (file (context-files context)) (render-file context file stream))
  (values))

(defun context-string (context)
  (with-output-to-string (stream) (render-context context stream)))

(defun write-context (context pathname)
  (with-open-file (stream pathname :direction :output :if-exists :supersede
                                  :if-does-not-exist :create :external-format :utf-8)
    (render-context context stream))
  pathname)
