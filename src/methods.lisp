;;;; ./source-context/src/methods.lisp

(in-package #:source-context)

(defmethod print-object ((context context) stream)
  (print-unreadable-object (context stream :type t :identity t)
    (format stream
            "~A files: ~D size: ~A"
            (context-root context)
            (length (context-files context))
            (format-byte-count
             (context-size context)))))

(defmethod print-object ((context asdf-context) stream)
  (print-unreadable-object (context stream :type t :identity t)
    (format stream
            "~%System: ~A~
             ~%Root: ~A~
             ~%Files: ~D, size: ~A"
            (context-system-name context)
            (context-root context)
            (length (context-files context))
            (format-byte-count
             (context-size context)))

    (dolist (file (context-files context))
      (format stream
              "~%  ~8A  ~A"
              (format-byte-count (file-size file))
              (relative-namestring context file)))))

(defmethod initialize-instance :after ((context asdf-context) &key)
  (let* ((system (asdf:find-system (context-system context)))
         (root (uiop:ensure-directory-pathname (asdf:system-source-directory system)))
         (asd-file (asdf:system-source-file system))
         (sources (collect-asdf-source-files system))
         (files (if (and (context-include-asd-p context) asd-file)
                    (cons asd-file (remove asd-file sources :test #'uiop:pathname-equal))
                    sources)))
    (setf (context-system context) system
          (slot-value context 'system-name) (asdf:component-name system)
          (slot-value context 'root) root
          (slot-value context 'asd-file) asd-file
          (context-files context) (remove-duplicates files :test #'uiop:pathname-equal))))

(defmethod list-files ((context context) &optional (stream *standard-output*))
  (loop for file in (context-files context) for index from 1
        do (format stream "~3D  ~A~%" index (relative-namestring context file)))
  (values))

(defmethod list-files ((context asdf-context) &optional (stream *standard-output*))
  (loop for file in (context-files context) for index from 1
        do (format stream "~3D  ~:[   ~;ASD~]  ~A~%" index
                   (and (context-asd-file context)
                        (uiop:pathname-equal file (context-asd-file context)))
                   (relative-namestring context file)))
  (values))

(defmethod list-components ((context context) &optional (stream *standard-output*))
  (list-files context stream))

(defmethod list-components ((context asdf-context) &optional (stream *standard-output*))
  (print-asdf-component (context-system context) (context-root context) stream 0)
  (values))

(defmethod context-summary ((context context) &optional (stream *standard-output*))
  (format stream "Context~%Root:   ~A~%Files:  ~D~%Size:   ~A~%Chars:  ~:D~%Tokens: ~:D (estimated)~%"
          (context-root context)
          (length (context-files context))
          (format-byte-count (context-size context))
          (context-character-count context)
          (context-token-count context))
  (values))

(defmethod context-summary ((context asdf-context) &optional (stream *standard-output*))
  (format stream "ASDF context~%System: ~A~%Root:   ~A~%ASD:    ~A~%Files:  ~D~%Size:   ~A~%"
          (context-system-name context) (context-root context)
          (if (context-asd-file context) (relative-namestring context (context-asd-file context)) "none")
          (length (context-files context)) (format-byte-count (context-size context)))
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
