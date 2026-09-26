(asdf:defsystem "ports-checker"
  :description
  "A targeted port checker that finds what’s listening on your servers—and flags what shouldn’t be."
  :author "Alexander Artemenko"
  :version "0.1.0"
  :class :40ants-asdf-system
  :defsystem-depends-on ("40ants-asdf-system")
  :pathname "src"
  :depends-on ("defmain"
               "ports-checker/main")
  :in-order-to ((test-op (test-op "ports-checker-tests"))))
