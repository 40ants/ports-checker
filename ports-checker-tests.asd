(asdf:defsystem "ports-checker-tests"
  :description
  "A targeted port checker that finds what’s listening on your servers—and flags what shouldn’t be."
  :class :40ants-asdf-system
  :defsystem-depends-on ("40ants-asdf-system")
  :pathname "tests"
  :depends-on ("ports-checker-tests/main")
  :perform (test-op (operation component)
             (declare (ignore operation component))
             (unless (symbol-call :rove :run :ports-checker-tests/main)
               (error "ports-checker tests failed: ~A" :rove))))
