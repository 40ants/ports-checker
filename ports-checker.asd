(asdf:defsystem "ports-checker"
  :description
  "A targeted port checker that finds what’s listening on your servers—and flags what shouldn’t be."
  :author "Alexander Artemenko <svetlyak.40wt@gmail.com>"
  :license "Unlicense"
  :homepage "https://40ants.com/ports-checker/"
  :source-control (:git "https://github.com/40ants/ports-checker")
  :bug-tracker "https://github.com/40ants/ports-checker/issues"
  :class :40ants-asdf-system
  :defsystem-depends-on ("40ants-asdf-system")
  :pathname "src"
  :depends-on ("defmain"
               "ports-checker/main")
  :in-order-to ((test-op (test-op "ports-checker-tests"))))
