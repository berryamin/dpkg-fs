#|
  This file is a part of dpkg-fs project.
|#

(in-package :cl-user)
(defpackage dpkg-fs-asd
  (:use :cl :asdf))
(in-package :dpkg-fs-asd)

(defsystem dpkg-fs
  :version "0.1"
  :author "Florian Margaine <florian@margaine.com>"
  :license "MIT License"
  :depends-on (:cl-fuse-meta-fs :cl-ppcre :log4cl :cl-annot :local-time)
  :components ((:module "src"
                :components
                ((:file "fuse" :depends-on ("dir-content"
                                            "is-directory"
                                            "symlink"
                                            "read-file"
                                            "execute-file"))
                 (:file "dir-content" :depends-on ("package"
                                                   "dpkg-fs"
                                                   "files"
                                                   "cache"))
                 (:file "is-directory" :depends-on ("dpkg-fs"
                                                    "files"
                                                    "cache"))
                 (:file "symlink" :depends-on ("dpkg-fs"
                                               "files"
                                               "cache"))
                 (:file "read-file" :depends-on ("package"
                                                 "dpkg-fs"
                                                 "cache"))
                 (:file "execute-file" :depends-on ("dpkg-fs"
                                                    "cache"))
                 (:file "package" :depends-on ("dpkg-fs"
                                               "files"
                                               "cache"))
                 (:file "files" :depends-on ("dpkg-fs"))
                 (:file "cache" :depends-on ("dpkg-fs"))
                 (:file "dpkg-fs"))))
  :description "dpkg implementation for pkgfs"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op dpkg-fs-test))))
