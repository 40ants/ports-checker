;;;; Probe discovered ports from the machine running ports-checker.

(uiop:define-package #:ports-checker/checker
  (:use #:cl)
  (:import-from #:usocket
                #:socket-close
                #:socket-connect)
  (:export #:check-ports
           #:probe-port))
(in-package #:ports-checker/checker)

(defun probe-port (host port &key (timeout 3))
  "Return true when a TCP connection to HOST and PORT succeeds within TIMEOUT."
  (handler-case
      (let ((socket (socket-connect host port
                                    :element-type '(unsigned-byte 8)
                                    :timeout timeout)))
        (unwind-protect
             t
          (socket-close socket)))
    (error ()
      nil)))

(defun check-ports (host discovered-ports allowed-ports
                    &key (timeout 3) (probe-function #'probe-port))
  "Return unexpected reachable ports among DISCOVERED-PORTS on HOST.

ALLOWED-PORTS are never probed.  PROBE-FUNCTION accepts HOST and PORT plus a
TIMEOUT keyword, which makes the network boundary replaceable in tests."
  (loop for port in discovered-ports
        unless (member port allowed-ports)
          when (funcall probe-function host port :timeout timeout)
            collect port))
