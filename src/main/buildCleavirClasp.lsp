(format t "Building cleavir clasp full version - loading compile-cclasp.lisp~%")
(defpackage #:cclasp-build
  (:use #:common-lisp #:core))
(in-package :cclasp-build)
(load "sys:kernel;cleavir;compile-cclasp.lisp")
(format t "Loading cleavir-system.lsp~%")
(load "sys:kernel;cleavir-system.lsp")
(core:load-system :bclasp :cclasp :system cclasp-build::*cleavir-system*)
(cclasp-build:compile-full-cclasp)
(core:quit)
