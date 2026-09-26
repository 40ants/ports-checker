(asdf:defsystem "ports-checker"
  :description "Check remotely listening TCP ports from an external host."
  :author "Alexander Artemenko"
  :version "0.1.0"
  :class :package-inferred-system
  :pathname "src"
  :depends-on ("ports-checker/main")
  :in-order-to ((test-op (test-op "ports-checker-tests"))))
