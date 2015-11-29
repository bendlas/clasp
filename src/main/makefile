# -*- mode: GNUmakefile; indent-tabs-mode: t -*-

include $(CLASP_HOME)/makefile.inc


project-directories = ../gctools ../core ../clbind ../cffi ../asttooling ../llvmo ../serveEvent ../sockets


ifneq ($(CLASP_INTERNAL_BUILD_TARGET_DIR),)
  BCLASP_BOEHMDC = $(CLASP_APP_EXECS)/boehmdc/release/bin/clasp -f bclasp
  BCLASP_BOEHM = $(CLASP_APP_EXECS)/boehm/release/bin/clasp -f bclasp
  CCLASP_BOEHMDC = $(CLASP_APP_EXECS)/boehmdc/release/bin/clasp
  CCLASP_BOEHM = $(CLASP_APP_EXECS)/boehm/release/bin/clasp
  CCLASP_MPS = $(CLASP_APP_EXECS)/mps/release/bin/clasp
else
  echo "ERROR CLASP_INTERNAL_BUILD_TARGET_DIR is not defined - what should I do now?"
endif

export CLASP_APP_RESOURCES_DIR=$(CLASP_INTERNAL_BUILD_TARGET_DIR)/Contents/Resources


clasp:
	$(MAKE) clasp-release
	$(MAKE) clasp-debug
.PHONY: clasp

clasp-debug:
	build -j$(PJOBS) gc=boehm link=static program=clasp release debug
.PHONY: clasp-debug

clasp-release:
	build -j$(PJOBS) gc=boehm link=static program=clasp release release
.PHONY: clasp-release

all:
	$(MAKE) boehm
#	$(MAKE) mps
.PHONY: all


link-cclasp-mps:
	$(CCLASP_MPS) -I -l "link-cclasp.lsp"
.PHONY: link-cclasp-mps

application:
	cp -R $(CLASP_INTERNAL_BUILD_TARGET_DIR) $(CLASP_APP_DIR)
.PHONY: application

boehm-cleavir:
	$(MAKE) boehm
	$(MAKE) cclasp
.PHONY: boehm-cleavir

cclasp-boehm-with-addons:
	$(MAKE) cclasp-boehm
	$(MAKE) cclasp-boehm-addons
.PHONY: cclasp-boehm-with-addons

clasp-reload:
	$(BCLASP_BOEHM) -l "buildCleavirClaspReload.lsp"
.PHONY: clasp-reload

bclasp-to-cclasp:
	$(BCLASP_BOEHM) -l "buildBclaspToCclasp.lsp"
.PHONY: bclasp-to-cclasp

bclasp-boehmdc-addons:
	$(BCLASP_BOEHMDC) -l "build_addons.lsp"
.PHONY: bclasp-boehmdc-addons

link-bclasp-boehmdc-addons:
	$(BCLASP_BOEHMDC) -l "link_addons.lsp"
.PHONY: link-bclasp-boehmdc-addons

cclasp-boehmdc-addons:
	$(CCLASP_BOEHMDC) -l "build_addons.lsp"
.PHONY: cclasp-boehmdc-addons

link-cclasp-boehmdc-addons:
	$(CCLASP_BOEHMDC) -l "link_addons.lsp"
.PHONY: link-cclasp-boehmdc-addons

cclasp-boehm-addons:
	$(CCLASP_BOEHM) -l "build_addons.lsp"
.PHONY: cclasp-boehm-addons

link-min-mps:
	$(CCLASP_MPS) -I -f ecl-min -l link-min.lsp
.PHONY: link-min-mps

link-cclasp-mps-addons:
	$(CCLASP_MPS) -l "link_addons.lsp"
.PHONY: link-cclasp-mps-addons

#	$(MAKE) clasp-gc-interface


boehmdc-release-cxx:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehmdc/release gc=boehmdc release clasp_install
.PHONY: boehmdc-release-cxx

boehmdc-release-cxx-a:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehmdc/release gc=boehmdc release clasp_install -a
.PHONY: boehmdc-release-cxx-a

boehm-release-cxx:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/release gc=boehm release clasp_install
.PHONY: boehm-release-cxx

boehm-release-cxx-a:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/release gc=boehm release clasp_install -a
.PHONY: boehm-release-cxx-a

mps-release-cxx:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/mps/release gc=mps release clasp_install
.PHONY: mps-release-cxx
mps-release-cxx-a:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/mps/release gc=mps release clasp_install -a
.PHONY: mps-release-cxx-a

boehmdc-debug-cxx:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehmdc/debug gc=boehmdc debug clasp_install
.PHONY: boehmdc-debug-cxx

boehm-debug-cxx:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/debug gc=boehm debug clasp_install
.PHONY: boehm-debug-cxx

boehm-debug-cxx-a:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/debug gc=boehm debug clasp_install -a
.PHONY: boehm-debug-cxx-a

mps-debug-cxx:
	$(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/mps/debug gc=mps debug clasp_install
.PHONY: mps-debug-cxx


min-boehm-clean:
	$(BCLASP_BOEHM) -I -f ecl-min -e "(clean-system :init :no-prompt t)" -e "(quit)"
.PHONY: min-boehm-clean

bclasp-boehm-clean:
	$(BCLASP_BOEHM) -I -f ecl-min -e "(bclasp-features)" -e "(clean-system :init :no-prompt t)" -e "(quit)"
.PHONY: bclasp-boehm-clean

cclasp-boehm-clean:
	$(BCLASP_BOEHM) -I -f ecl-min -e "(cclasp-features)" -e "(clean-system :init :no-prompt t)" -e "(quit)"
.PHONY: cclasp-boehm-clean

min-boehm:
	$(BCLASP_BOEHM) -I -f ecl-min -e "(compile-min)" -e "(link-min)" -e "(quit)"
.PHONY: min-boehm

min-boehmdc:
	$(BCLASP_BOEHMDC) -I -f ecl-min -e "(compile-min)" -e "(link-min)" -e "(quit)"
.PHONY: min-boehmdc

bclasp-boehmdc-bitcode:
	$(BCLASP_BOEHMDC) -f ecl-min -e "(compile-bclasp)" -e "(quit)"
.PHONY: bclasp-boehmdc-bitcode

bclasp-boehmdc-fasl:
	$(BCLASP_BOEHMDC) -f ecl-min -e "(link-bclasp)" -e "(quit)"
.PHONY: bclasp-boehmdc-fasl

cclasp-boehmdc-bitcode:
	$(BCLASP_BOEHMDC) -f ecl-min -e "(compile-cclasp)" -e "(quit)"
.PHONY: cclasp-boehmdc-bitcode

cclasp-boehmdc-fasl:
	$(BCLASP_BOEHMDC) -f ecl-min -e "(link-cclasp :force t)" -e "(quit)"
.PHONY: cclasp-boehmdc-fasl
bclasp-boehm:
	$(MAKE) bclasp-boehm-bitcode
	$(MAKE) bclasp-boehm-fasl
.PHONY: bclasp-boehm

bclasp-boehm-bitcode:
	$(BCLASP_BOEHM) -f ecl-min -e "(compile-bclasp)" -e "(quit)"
.PHONY: bclasp-boehm-bitcode

bclasp-boehm-fasl:
	$(BCLASP_BOEHM) -f ecl-min -e "(link-bclasp)" -e "(quit)"
.PHONY: bclasp-boehm-fasl

bclasp-boehm-addons:
	$(BCLASP_BOEHM) -l "build_addons.lsp"
.PHONY: bclasp-boehm-addons

bclasp-boehm-addons-fasl:
	$(BCLASP_BOEHM) -l "link-addons.lsp"
.PHONY: bclasp-boehm-addons-fasl

cclasp-from-bclasp-boehm-bitcode:
	$(BCLASP_BOEHM) -l "buildCleavirClasp.lsp"
.PHONY: cclasp-from-bclasp-boehm-bitcode

cclasp-boehm:
	$(MAKE) cclasp-from-bclasp-boehm-bitcode
	$(MAKE) cclasp-boehm-fasl
.PHONY: cclasp-boehm

cclasp-boehm-bitcode:
	$(BCLASP_BOEHM) -f ecl-min -e "(compile-cclasp)" -e "(quit)"
.PHONY: cclasp-boehm-bitcode

cclasp-boehm-fasl:
	$(BCLASP_BOEHM) -f ecl-min -e "(link-cclasp :force t)" -e "(quit)"
.PHONY: cclasp-boehm-fasl




clasp-gc-interface:
	$(BCLASP_BOEHM) -l "buildClaspGC.lsp"
.PHONY: clasp-gc-interface

debug-mps:
	export CLASP_TELEMETRY_MASK=1
	export CLASP_TELEMETRY_FILE=/tmp/clasp.tel
	export CLASP_MPS_DEBUG="32 32 16 80 32 80"
	bash
.PHONY: debug-mps




scrape-all:
	(export PYTHONPATH=$(CLASP_HOME)/src/common:$(PYTHONPATH); $(PYTHON2) $(CLASP_HOME)/src/common/symbolGroveler.py include/generated/symbols_scraped_inc.h $(project-directories))
	(export PYTHONPATH=$(CLASP_HOME)/src/common:$(PYTHONPATH); $(PYTHON2) $(CLASP_HOME)/src/common/classGroveler.py include/generated/initClasses_inc.h $(project-directories) 2>registerClasses.log)
.PHONY: scrape-all



run-clang-check:
	clang-check -p . main.cc
.PHONY: run-clang-check

run-clasp:
	clasp_d clang0.lsp
.PHONY: run-clasp

mps-interface-clasp:
	@echo Generating compile-commands
	$(MAKE) compile-commands
	@echo Running parallel search and generating code when done
	$(BCLASP_BOEHM) -l "sys:mps-interface.lsp" -e "(parallel-search-all-then-generate-code-and-quit)"
.PHONY: mps-interface-clasp

compile-commands:
	-bjam link=static gc=mps-prep program=clasp link=static -n -a >bjam.out
	-install -d $(CLASP_APP_RESOURCES_DIR)/build-databases
	python ../common/buildJSON.py clang bjam.out `$(BCLASP_BOEHMDC) -N -e "(progn (format t \"~a\"(namestring (translate-logical-pathname (ensure-directories-exist #P\"APP-RESOURCES:build-databases;clasp_compile_commands.json\")))) (quit))"` # $(CLASP_APP_RESOURCES_DIR)/build-databases/clasp_compile_commands.json
.PHONY: compile-commands

mps-interface-run:
	$(BCLASP_BOEHMDC)  \
		-e "(require :asdf)" \
	        -e "(asdf:load-system \"clasp-analyzer\")" \
		-e "(clasp-analyzer:load-compilation-database \"app-resources:build-databases;clasp_compile_commands.json\")" \
	        -e "(clasp-analyzer:serial-search-all-then-generate-code-and-quit)"
.PHONY: mps-interface-run

mps-interface:
	@echo Building mps-prep
	build -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/mps-prep/$(VARIANT) gc=mps-prep release clasp_install
	$(MAKE) compile-commands
	$(MAKE) mps-interface-run
.PHONY: mps-interface
