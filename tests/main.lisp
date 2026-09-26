;;;; Test suite.

(uiop:define-package #:ports-checker-tests/main
  (:use #:cl #:rove)
  (:import-from #:ports-checker/checker
                #:check-ports)
  (:import-from #:ports-checker/main
                #:parse-allowed-ports)
  (:import-from #:ports-checker/remote
                #:parse-ss-output))
(in-package #:ports-checker-tests/main)

(deftest parse-allowed-ports-test
  (testing "a comma-separated value becomes a unique list of ports"
    (ok (equal '(22 80 443)
               (parse-allowed-ports "22,80,443,80"))))
  (testing "spaces around comma-separated ports are accepted"
    (ok (equal '(22 80 443)
               (parse-allowed-ports "22, 80, 443"))))
  (testing "empty and out-of-range ports are rejected"
    (signals (parse-allowed-ports "22,,443"))
    (signals (parse-allowed-ports "70000"))))

(deftest parse-ss-output-test
  (testing "wildcard and public listeners are returned once"
    (ok (equal '(22 443 8080)
               (parse-ss-output
                (format nil
                        "LISTEN 0 128 0.0.0.0:22 0.0.0.0:*~%~
                         LISTEN 0 128 [::]:22 [::]:*~%~
                         LISTEN 0 128 192.0.2.10:443 0.0.0.0:*~%~
                         LISTEN 0 128 *:8080 *:*~%")))))
  (testing "loopback listeners are omitted"
    (ok (equal nil
               (parse-ss-output
                (format nil
                        "LISTEN 0 128 127.0.0.1:3000 0.0.0.0:*~%~
                         LISTEN 0 128 127.10.20.30:4000 0.0.0.0:*~%~
                         LISTEN 0 128 [::1]:5000 [::]:*~%"))))))

(deftest check-ports-test
  (testing "allowed ports are not probed and reachable unexpected ports fail"
    (let ((probed nil))
      (ok (equal '(8080)
                 (check-ports
                  "example.test"
                  '(22 443 8080 9000)
                  '(22 443)
                  :timeout 7
                  :probe-function
                  (lambda (host port &key timeout)
                    (push (list host port timeout) probed)
                    (= port 8080)))))
      (ok (equal '(("example.test" 9000 7)
                   ("example.test" 8080 7))
                 probed)))))
