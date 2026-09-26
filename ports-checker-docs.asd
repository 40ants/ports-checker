(asdf:defsystem "ports-checker-docs"
  :author "Alexander Artemenko <svetlyak.40wt@gmail.com>"
  :license "Unlicense"
  :homepage "https://40ants.com/ports-checker/"
  :description
  "A targeted port checker that finds what’s listening on your servers—and flags what shouldn’t be."
  :source-control (:git "https://github.com/40ants/ports-checker")
  :bug-tracker "https://github.com/40ants/ports-checker/issues"
  :class :40ants-asdf-system
  :defsystem-depends-on ("40ants-asdf-system")
  :pathname "docs"
  :depends-on ("ports-checker"
               "ports-checker-docs/index"))
