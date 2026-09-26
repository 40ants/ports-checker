;;;; Project changelog.

(uiop:define-package #:ports-checker-docs/changelog
  (:use #:cl)
  (:import-from #:40ants-doc/changelog
                #:defchangelog))
(in-package #:ports-checker-docs/changelog)

(defchangelog (:ignore-words ("SSH"
                              "TCP"))
  (0.1.0 2026-09-26
         "* Added discovery of non-loopback TCP listeners over SSH.
* Added external reachability checks for discovered ports.
* Added comma-separated allowlists and meaningful process exit codes."))
