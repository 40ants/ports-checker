(uiop:define-package #:ports-checker/main
  (:use #:cl)
  (:import-from #:ports-checker/checker
                #:check-ports)
  (:import-from #:ports-checker/remote
                #:discover-ports)
  (:import-from #:defmain)
  (:export #:main
           #:parse-allowed-ports))
(in-package #:ports-checker/main)

(defparameter +usage+
  "Usage: ports-checker [options] HOST

Check remote TCP listeners and fail if an unapproved port is reachable.

Options:
  -a, --allow PORTS      Allowed TCP ports separated by commas
  -u, --ssh-user USER    SSH user
  -p, --ssh-port PORT    SSH port
      --ssh-timeout SEC  SSH connection timeout (default: 10)
  -t, --timeout SEC      TCP probe timeout (default: 3)
  -h, --help             Show this help")

(define-condition command-line-error (error)
  ((message :initarg :message :reader command-line-error-message))
  (:report (lambda (condition stream)
             (format stream "~A" (command-line-error-message condition)))))

(defun %bounded-positive-integer (value option maximum)
  (handler-case
      (let ((number (parse-integer value :junk-allowed nil)))
        (unless (<= 1 number maximum)
          (error 'command-line-error
                 :message (format nil "~A expects an integer from 1 to ~D, got ~S"
                                  option maximum value)))
        number)
    (parse-error ()
      (error 'command-line-error
             :message (format nil "~A expects an integer from 1 to ~D, got ~S"
                              option maximum value)))))

(defun parse-allowed-ports (value)
  "Parse comma-separated allowed ports from VALUE and return unique integers."
  (when value
    (remove-duplicates
     (loop for item in (uiop:split-string value :separator '(#\,))
           for port = (string-trim '(#\Space #\Tab) item)
           when (zerop (length port))
             do (error 'command-line-error
                       :message (format nil "--allow contains an empty port: ~S" value))
           collect (%bounded-positive-integer port "--allow" 65535))
     :from-end t)))

(defmain:defmain (%run :program-name "ports-checker")
    ((help "Show help on this program." :flag t :short "h")
     (allow "Allowed TCP ports separated by commas." :short "a")
     (ssh-user "SSH user." :short "u")
     (ssh-port "SSH port." :short "p")
     (ssh-timeout "SSH connection timeout in seconds." :short nil :default "10")
     (timeout "TCP probe timeout in seconds." :short "t" :default "3")
     &rest hosts
     :catch-errors nil)
  "Check remote TCP listeners and fail if an unapproved port is reachable."
  (when help
    (format t "~A~%" +usage+)
    (return-from %run 0))
  (unless (= (length hosts) 1)
    (error 'command-line-error
           :message "Exactly one HOST argument is required"))
  (let* ((host (first hosts))
         (allowed-ports (parse-allowed-ports allow))
         (parsed-ssh-port (when ssh-port
                            (%bounded-positive-integer ssh-port "--ssh-port" 65535)))
         (parsed-ssh-timeout
           (%bounded-positive-integer ssh-timeout "--ssh-timeout" most-positive-fixnum))
         (parsed-timeout
           (%bounded-positive-integer timeout "--timeout" most-positive-fixnum))
         (ports (discover-ports host
                                :ssh-user ssh-user
                                :ssh-port parsed-ssh-port
                                :connect-timeout parsed-ssh-timeout))
         (unexpected (check-ports host
                                  ports
                                  allowed-ports
                                  :timeout parsed-timeout)))
    (if unexpected
        (progn
          (dolist (port unexpected)
            (format *error-output*
                    "ERROR: unapproved TCP port ~D is reachable on ~A~%"
                    port host))
          1)
        (progn
          (format t "OK: no unapproved TCP ports are reachable on ~A~%" host)
          0))))

(defun main (&optional (arguments (uiop:command-line-arguments)))
  "Run ports-checker with ARGUMENTS and return a process exit code."
  (handler-case
      (apply #'%run arguments)
    (error (condition)
      (format *error-output* "ERROR: ~A~%" condition)
      2)))
