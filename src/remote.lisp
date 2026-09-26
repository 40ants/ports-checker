;;;; Discover TCP listeners through SSH.

(uiop:define-package #:ports-checker/remote
  (:use #:cl)
  (:export #:discover-ports
           #:parse-ss-output
           #:remote-command-error))
(in-package #:ports-checker/remote)

(define-condition remote-command-error (error)
  ((destination :initarg :destination :reader remote-command-error-destination)
   (status :initarg :status :reader remote-command-error-status)
   (stderr :initarg :stderr :reader remote-command-error-stderr))
  (:report (lambda (condition stream)
             (format stream "Unable to inspect ~A over SSH (exit ~D): ~A"
                     (remote-command-error-destination condition)
                     (remote-command-error-status condition)
                     (remote-command-error-stderr condition)))))

(defun %split-whitespace (string)
  (loop with length = (length string)
        for start = (position-if-not (lambda (character)
                                       (find character " \t"))
                                     string)
          then (position-if-not (lambda (character)
                                  (find character " \t"))
                                string
                                :start end)
        while start
        for end = (or (position-if (lambda (character)
                                     (find character " \t"))
                                   string
                                   :start start)
                      length)
        collect (subseq string start end)
        while (< end length)))

(defun %parse-endpoint (endpoint)
  (let ((separator (position #\: endpoint :from-end t)))
    (when separator
      (let* ((raw-address (subseq endpoint 0 separator))
             (address (string-trim "[]" raw-address))
             (port-text (subseq endpoint (1+ separator))))
        (handler-case
            (let ((port (parse-integer port-text)))
              (if (<= 1 port 65535)
                  (values address port)
                  (values nil nil)))
          (parse-error ()
            (values nil nil)))))))

(defun %loopback-address-p (address)
  (or (string= address "::1")
      (string= address "localhost")
      (and (<= 4 (length address))
           (string= address "127." :end1 4 :end2 4))))

(defun parse-ss-output (output)
  "Return sorted unique TCP ports bound to wildcard or non-loopback addresses.

OUTPUT must be produced by `ss -H -lnt`.  Loopback-only listeners are omitted."
  (sort
   (remove-duplicates
    (loop for line in (uiop:split-string output :separator '(#\Newline #\Return))
          for fields = (%split-whitespace line)
          when (>= (length fields) 5)
            append (multiple-value-bind (address port)
                       (%parse-endpoint (nth 3 fields))
                     (if (and port (not (%loopback-address-p address)))
                         (list port)
                         nil))))
   #'<))

(defun discover-ports (destination &key ssh-user ssh-port (connect-timeout 10))
  "Return externally bound TCP ports reported by DESTINATION over SSH.

SSH-USER and SSH-PORT select the SSH account and port.  CONNECT-TIMEOUT is
passed to OpenSSH.  Authentication is deliberately non-interactive."
  (let* ((target (if ssh-user
                     (format nil "~A@~A" ssh-user destination)
                     destination))
         (command (append (list "ssh"
                                "-o" "BatchMode=yes"
                                "-o" "StrictHostKeyChecking=yes"
                                "-o" (format nil "ConnectTimeout=~D" connect-timeout))
                          (when ssh-port
                            (list "-p" (princ-to-string ssh-port)))
                          (list "--" target "ss -H -lnt"))))
    (multiple-value-bind (stdout stderr status)
        (uiop:run-program command
                          :output :string
                          :error-output :string
                          :ignore-error-status t)
      (unless (zerop status)
        (error 'remote-command-error
               :destination destination
               :status status
               :stderr (string-trim '(#\Space #\Tab #\Newline #\Return) stderr)))
      (parse-ss-output stdout))))
