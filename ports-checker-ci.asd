(asdf:defsystem "ports-checker-ci"
  :author "Alexander Artemenko <svetlyak.40wt@gmail.com>"
  :license "Unlicense"
  :homepage "https://40ants.com/ports-checker/"
  :description "Provides CI settings for ports-checker."
  :source-control (:git "https://github.com/40ants/ports-checker")
  :bug-tracker "https://github.com/40ants/ports-checker/issues"
  :class :40ants-asdf-system
  :defsystem-depends-on ("40ants-asdf-system")
  :pathname "src"
  :depends-on ("40ants-ci"
               "ports-checker-ci/ci"))
