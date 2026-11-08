(in-package #:source-context)

(defclass asdf-context (context)
  ((system :initarg :system :accessor context-system)
   (system-name :accessor context-system-name)
   (asd-file :accessor context-asd-file)
   (include-asd-p :initarg :include-asd-p :initform t :reader context-include-asd-p)))

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

(defun collect-asdf-source-files (component)
  (labels ((walk (component)
             (cond ((typep component 'asdf:source-file)
                    (let ((pathname (asdf:component-pathname component)))
                      (if pathname (list pathname) nil)))
                   ((typep component 'asdf:parent-component)
                    (mapcan #'walk (asdf:component-children component)))
                   (t nil))))
    (walk component)))

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

(defun make-asdf-context (system &key (include-asd-p t)
                                      (exclude-directories '(".git" "generated")) exclude-files)
  (make-instance 'asdf-context :system system :include-asd-p include-asd-p
                 :exclude-directories exclude-directories :exclude-files exclude-files))

(defmethod context-summary ((context asdf-context) &optional (stream *standard-output*))
  (format stream "ASDF context~%System: ~A~%Root:   ~A~%ASD:    ~A~%Files:  ~D~%Size:   ~A~%"
          (context-system-name context) (context-root context)
          (if (context-asd-file context) (relative-namestring context (context-asd-file context)) "none")
          (length (context-files context)) (format-byte-count (context-size context)))
  (values))

(defmethod list-files ((context asdf-context) &optional (stream *standard-output*))
  (loop for file in (context-files context) for index from 1
        do (format stream "~3D  ~:[   ~;ASD~]  ~A~%" index
                   (and (context-asd-file context)
                        (uiop:pathname-equal file (context-asd-file context)))
                   (relative-namestring context file)))
  (values))

(defun print-asdf-component (component root stream depth)
  (let ((pathname (ignore-errors (asdf:component-pathname component)))
        (kind (cond ((typep component 'asdf:system) "system")
                    ((typep component 'asdf:module) "module")
                    ((typep component 'asdf:source-file) "file")
                    (t "component"))))
    (format stream "~V@T[~A] ~A" (* depth 2) kind (asdf:component-name component))
    (when (and pathname (typep component 'asdf:source-file))
      (format stream "  -> ~A" (enough-namestring pathname root)))
    (terpri stream)
    (when (typep component 'asdf:parent-component)
      (dolist (child (asdf:component-children component))
        (print-asdf-component child root stream (1+ depth))))))

(defmethod list-components ((context asdf-context) &optional (stream *standard-output*))
  (print-asdf-component (context-system context) (context-root context) stream 0)
  (values))
