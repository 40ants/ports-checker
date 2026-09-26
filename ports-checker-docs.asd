(asdf:defsystem "ports-checker-docs"
  :author "Alexander Artemenko"
  :homepage "https://40ants.com/ports-checker/"
  :description "Documentation for ports-checker."
  :source-control (:git "https://github.com/40ants/ports-checker")
  :bug-tracker "https://github.com/40ants/ports-checker/issues"
  :class :package-inferred-system
  :pathname "docs"
  :depends-on ("ports-checker"
               "ports-checker-docs/index"))
