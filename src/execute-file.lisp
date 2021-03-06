(in-package :dpkg-fs)

(defgeneric execute-file (path type &key)
  (:documentation "Determines if a file is executable."))

(defmethod execute-file (path (type (eql :root)) &key)
  (unless path
    (return-from execute-file nil))
  (cond ((member (first path) '("sync" "upgrade") :test #'string=) t)
        ((string= (first path) "installed") (execute-file (rest path) :installed))
        ((string= (first path) "index") (execute-file (rest path) :index))))

(defmethod execute-file (path (type (eql :index)) &key)
  (with-apt-cache ("execute-index" path)
    (unless path
      (return-from execute-file nil))
    (when (package-available (first path))
      (execute-file (rest path) :package-index-info :package (first path)))))

(defmethod execute-file (path (type (eql :package-index-info)) &key package)
  (unless path
    (return-from execute-file nil))
  (and (= (length path) 1) (string= (first path) "install")))

(defmethod execute-file (path (type (eql :installed)) &key)
  (with-dpkg-cache ("execute-installed" path)
    (unless path
      (return-from execute-file nil))
    (when (package-exists (first path))
      (execute-file (rest path) :package-info :package (first path)))))

(defmethod execute-file (path (type (eql :package-info)) &key package)
  (unless path
    (return-from execute-file nil))
  (and (= (length path) 1) (string= (first path) "uninstall")))
