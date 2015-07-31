(in-package :dpkg-fs)

(defun run (command)
  (let ((s (make-string-output-stream)))
    (uiop:run-program command :ignore-error-status t :output s)
    (get-output-stream-string s)))

(defn installed-packages (list) ()
  (cl-ppcre:split " " (run "dpkg-query --showformat='${Package} ' --show")))

(defn all-packages (list) ()
  (mapcar #'(lambda (item)
              (first (cl-ppcre:split " " item)))
          (cl-ppcre:split #\Newline (run "apt-cache search ."))))

(defn package-exists (string -> boolean) (name)
  (string= "install ok installed"
           (run (cat "dpkg-query --showformat='${Status}' --show " name))))

(defn package-available (string -> boolean) (name)
  (> (length (cl-ppcre:split #\Newline (run (cat "apt-cache search " name))))
     0))

(defn package-deps (string -> list) (name)
  ;; @todo handle OR dependencies correctly, e.g. foo | bar
  ;; means "use and install foo if possible, but use bar
  ;; if it's already there".
  (mapcar
   #'(lambda (dep)
       (first (cl-ppcre:split " " dep)))
   (cl-ppcre:split
    ", "
    (run (cat "dpkg-query --showformat='${Depends}' --show " name)))))

(defn package-index-deps (string -> list) (name)
  ;; @todo handle OR dependencies, or virtual packages.
  (remove-if #'is-empty-string
             (mapcar
              #'get-dependency
              (remove-if-not #'is-depends-line
                             (cl-ppcre:split #\Newline (run (cat "apt-cache depends " name)))))))

(defn get-dependency (string -> string) (line)
  (multiple-value-bind (_ name)
      (cl-ppcre:scan-to-strings "^\\s+Depends:\\s+([a-zA-Z0-9-_.]+)$" line)
    (declare (ignore _))
    (if name
        (elt name 0)
        "")))

(defn is-empty-string (string -> boolean) (str)
  (string= str ""))

(defn is-depends-line (string -> boolean) (line)
  (if (cl-ppcre:scan "^\\s+Depends:.*$" line)
      t
      nil))

(defn package-version (string -> string) (name)
  (run (cat "dpkg-query --showformat='${Version}' --show " name)))

(defn package-desc (string -> string) (name)
  (run (cat "dpkg-query --showformat='${Description}' --show " name)))

(defn package-index-version (string -> string) (name)
  (multiple-value-bind (_ matches)
      (cl-ppcre:scan-to-strings "Version: (.*)" (run (cat "apt-cache show " name)))
    (declare (ignore _))
    (elt matches 0)))

(defn package-index-desc (string -> string) (name)
  (multiple-value-bind (_ matches)
      (cl-ppcre:scan-to-strings "Description-\\w+:\\s(.*)" (run (cat "apt-cache show " name)))
    (declare (ignore _))
    (elt matches 0)))
