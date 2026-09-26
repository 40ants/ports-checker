(asdf:defsystem "ports-checker-tests"
  :description "Tests for ports-checker."
  :class :package-inferred-system
  :pathname "tests"
  :depends-on ("ports-checker-tests/main")
  :perform (test-op (operation component)
             (declare (ignore operation component))
             (unless (symbol-call :rove :run :ports-checker-tests/main)
               (error "ports-checker tests failed: ~A" :rove))))
