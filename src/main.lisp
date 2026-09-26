;;;; Command-line interface.

(uiop:define-package #:ports-checker/main
  (:use #:cl)
  (:import-from #:ports-checker/checker
                #:check-ports)
  (:import-from #:ports-checker/remote
                #:discover-ports)
  (:export #:main))
(in-package #:ports-checker/main)

(defparameter +usage+
  "Usage: ports-checker [options] HOST

Check TCP ports reported by HOST and fail if an unapproved port is reachable.

Options:
  -a, --allow PORT       Allow PORT (repeatable)
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

(defun %option-value (arguments option)
  (unless (rest arguments)
    (error 'command-line-error
           :message (format nil "~A requires a value" option)))
  (second arguments))

(defun %parse-arguments (arguments)
  (loop with allowed-ports = nil
        with ssh-user = nil
        with ssh-port = nil
        with ssh-timeout = 10
        with timeout = 3
        with host = nil
        while arguments
        for argument = (pop arguments)
        do (cond
             ((member argument '("-h" "--help") :test #'string=)
              (return (list :help t)))
             ((member argument '("-a" "--allow") :test #'string=)
              (let ((value (%option-value (cons argument arguments) argument)))
                (pop arguments)
                (push (%bounded-positive-integer value argument 65535) allowed-ports)))
             ((member argument '("-u" "--ssh-user") :test #'string=)
              (setf ssh-user (%option-value (cons argument arguments) argument))
              (pop arguments))
             ((member argument '("-p" "--ssh-port") :test #'string=)
              (let ((value (%option-value (cons argument arguments) argument)))
                (pop arguments)
                (setf ssh-port (%bounded-positive-integer value argument 65535))))
             ((string= argument "--ssh-timeout")
              (let ((value (%option-value (cons argument arguments) argument)))
                (pop arguments)
                (setf ssh-timeout
                      (%bounded-positive-integer value argument most-positive-fixnum))))
             ((member argument '("-t" "--timeout") :test #'string=)
              (let ((value (%option-value (cons argument arguments) argument)))
                (pop arguments)
                (setf timeout
                      (%bounded-positive-integer value argument most-positive-fixnum))))
             ((and (plusp (length argument))
                   (char= (char argument 0) #\-))
              (error 'command-line-error
                     :message (format nil "Unknown option: ~A" argument)))
             (host
              (error 'command-line-error
                     :message (format nil "Unexpected argument: ~A" argument)))
             (t
              (setf host argument)))
        finally
           (unless host
             (error 'command-line-error :message "HOST is required"))
           (return (list :host host
                         :allowed-ports allowed-ports
                         :ssh-user ssh-user
                         :ssh-port ssh-port
                         :ssh-timeout ssh-timeout
                         :timeout timeout))))

(defun main (&optional (arguments (uiop:command-line-arguments)))
  "Run ports-checker with ARGUMENTS and return a process exit code."
  (handler-case
      (let ((options (%parse-arguments arguments)))
        (when (getf options :help)
          (format t "~A~%" +usage+)
          (return-from main 0))
        (let* ((host (getf options :host))
               (ports (discover-ports host
                                      :ssh-user (getf options :ssh-user)
                                      :ssh-port (getf options :ssh-port)
                                      :connect-timeout (getf options :ssh-timeout)))
               (unexpected (check-ports host
                                        ports
                                        (getf options :allowed-ports)
                                        :timeout (getf options :timeout))))
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
    (error (condition)
      (format *error-output* "ERROR: ~A~%" condition)
      2)))
