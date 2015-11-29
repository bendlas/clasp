# -*- mode: GNUmakefile; indent-tabs-mode: t -*-
# Cleaned up by Shinmera October 13, 2015

export CLASP_HOME ?= $(shell pwd)

include $(wildcard $(CLASP_HOME)/local.config)

export PJOBS ?= 1

export TARGET_OS ?= $(shell uname)
export TARGET_OS := $(or $(filter $(TARGET_OS), Linux),\
                         $(filter $(TARGET_OS), Darwin),\
                         $(error Invalid TARGET_OS: $(TARGET_OS)))

export ADDRESS-MODEL ?= 64
export ADDRESS-MODEL := $(or $(filter $(ADDRESS-MODEL), 64),\
                             $(error Invalid ADDRESS-MODEL: $(ADDRESS-MODEL)))

export LINK ?= shared
export LINK := $(or $(filter $(LINK), shared),\
                    $(filter $(LINK), static),\
                    $(error Invalid LINK: $(LINK)))


export VARIANT ?= release
export VARIANT := $(or $(filter $(VARIANT), debug),\
                       $(filter $(VARIANT), release),\
                       $(error Invalid VARIANT: $(VARIANT)))

export TOOLSET ?= $(or $(and $(filter $(TARGET_OS),Linux), clang-linux),\
                       $(and $(filter $(TARGET_OS),Darwin), clang-darwin))
export TOOLSET := $(or $(filter $(TOOLSET), clang-linux),\
                       $(filter $(TOOLSET), clang-darwin),\
                       $(error Invalid TOOLSET: $(TOOLSET)))

# From the GNU Make manual; portably search PATH for a program. We can't rely on `which` existing...
# Use $(call pathsearch,foo) instead of $(shell which foo)
pathsearch = $(firstword $(wildcard $(addsuffix /$(strip $(1)),$(subst :, ,$(PATH)))))

export PYTHON2 := $(or $(PYTHON2),\
                       $(call pathsearch, python2.7),\
                       $(call pathsearch, python2),\
                       $(call pathsearch, python),\
                       $(error Could not find python.))

export EXECUTABLE_DIR ?= $(or $(and $(filter $(TARGET_OS),Linux), bin),\
                              $(and $(filter $(TARGET_OS),Darwin), MacOS))

export DEVEMACS ?= $(or $(and $(filter $(TARGET_OS),Linux), emacs -nw ./),\
                        $(and $(filter $(TARGET_OS),Darwin), open -n -a /Applications/Emacs.app ./))

ifneq ($(EXTERNALS_CLASP_DIR),)
export LLVM_CONFIG := $(or $(LLVM_CONFIG),\
                           $(wildcard $(EXTERNALS_CLASP_DIR)/build/release/bin/llvm-config),\
                           $(error Could not find llvm-config (release build) in externals-clasp.))
export LLVM_CONFIG_DEBUG := $(or $(LLVM_CONFIG_DEBUG),\
                                 $(wildcard $(EXTERNALS_CLASP_DIR)/build/debug/bin/llvm-config),\
                                 $(warning Could not find llvm-config (debug build) in externals-clasp.),\
                                 $(LLVM_CONFIG))
else
# XXX: confirm the necessity of llvm-config* pathsearch!
export LLVM_CONFIG ?= $(or $(call pathsearch, llvm-config),\
                           $(call pathsearch, llvm-config*),\
                           $(error Could not find llvm-config.))
endif

export GIT_COMMIT ?= $(shell git rev-parse --short HEAD || echo "unknown-commit")
export CLASP_VERSION ?= $(shell git describe --always || echo "unknown-version")

export LLVM_CONFIG_RELEASE ?= $(LLVM_CONFIG)
export LLVM_CONFIG_DEBUG ?= $(LLVM_CONFIG)

export LLVM_BIN_DIR ?= $(shell $(LLVM_CONFIG_RELEASE) --bindir)
# Not always the same as LLVM_BIN_DIR!
export CLANG_BIN_DIR ?= $(if $(wildcard $(LLVM_BIN_DIR)/clang),$(LLVM_BIN_DIR),$(dir $(or $(call pathsearch, clang),\
                                        $(error Could not find clang.))))

export CLASP_INTERNAL_BUILD_TARGET_DIR ?= $(shell pwd)/build/clasp

export LIBATOMIC_OPS_SOURCE_DIR ?= $(CLASP_HOME)/src/boehm/libatomic_ops
export BOEHM_SOURCE_DIR ?= $(CLASP_HOME)/src/boehm/bdwgc
export BUILD ?= $(CLASP_HOME)/src/common/build
export CLASP_APP_EXECS ?= $(CLASP_INTERNAL_BUILD_TARGET_DIR)/Contents/execs
export CLASP_APP_RESOURCES_DIR ?= $(CLASP_INTERNAL_BUILD_TARGET_DIR)/Contents/Resources
export CLASP_APP_RESOURCES_LIB_COMMON_DIR ?= $(CLASP_INTERNAL_BUILD_TARGET_DIR)/Contents/Resources/lib/common

export BOOST_BUILD_SOURCE_DIR ?= $(CLASP_HOME)/tools/boost_build
export BOOST_BUILD_INSTALL ?= $(CLASP_APP_RESOURCES_DIR)/boost_build
export BJAM ?= $(BOOST_BUILD_INSTALL)/bin/bjam --ignore-site-config --user-config= -q

export CLASP_DEBUG_LLVM_LIB_DIR ?= $(shell $(LLVM_CONFIG_DEBUG) --libdir | tr -d '\n')
export CLASP_RELEASE_LLVM_LIB_DIR ?= $(shell $(LLVM_CONFIG_RELEASE) --libdir | tr -d '\n')

export CLASP_DEBUG_CXXFLAGS += -I$(shell $(LLVM_CONFIG_DEBUG) --includedir)
export CLASP_DEBUG_LINKFLAGS += -L$(CLASP_DEBUG_LLVM_LIB_DIR)
export CLASP_DEBUG_LINKFLAGS += $(shell $(LLVM_CONFIG_DEBUG) --libs)
export CLASP_DEBUG_LINKFLAGS += $(shell $(LLVM_CONFIG_DEBUG) --system-libs)
export CLASP_RELEASE_CXXFLAGS += -I$(shell $(LLVM_CONFIG_RELEASE) --includedir)
export CLASP_RELEASE_LINKFLAGS += -L$(CLASP_RELEASE_LLVM_LIB_DIR)
export CLASP_RELEASE_LINKFLAGS += $(shell $(LLVM_CONFIG_RELEASE) --libs)
export CLASP_RELEASE_LINKFLAGS += $(shell $(LLVM_CONFIG_RELEASE) --system-libs)

ifneq ($(EXTERNALS_CLASP_DIR),)
  export CLASP_DEBUG_CXXFLAGS += -I$(EXTERNALS_CLASP_DIR)/build/common/include
  export CLASP_DEBUG_LINKFLAGS += -L$(EXTERNALS_CLASP_DIR)/build/common/lib -lgmp -lgmpxx -lreadline -lexpat
  export CLASP_RELEASE_CXXFLAGS += -I$(EXTERNALS_CLASP_DIR)/build/common/include
  export CLASP_RELEASE_LINKFLAGS += -L$(EXTERNALS_CLASP_DIR)/build/common/lib -lgmp -lgmpxx -lreadline -lexpat
endif

ifeq ($(TARGET_OS),Darwin)
  export INCLUDE_DIRS += /usr/local/Cellar/gmp/6.0.0a/include
  export INCLUDE_DIRS += /opt/local/include
  export LIB_DIRS += /usr/local/Cellar/gmp/6.0.0a/lib
  export LIB_DIRS += /opt/local/lib
  export BOEHM_CC = gcc
  export BOEHM_CXX = g++
endif

ifeq ($(TARGET_OS),Linux)
  export BOEHM_CC = $(CLANG_BIN_DIR)/clang
  export BOEHM_CXX = $(CLANG_BIN_DIR)/clang++
endif

include_flags := $(foreach dir,$(INCLUDE_DIRS),$(and $(wildcard $(dir)),-I$(dir)))
lib_flags := $(foreach dir,$(LIB_DIRS),$(and $(wildcard $(dir)),-L$(dir)))
export CLASP_DEBUG_CXXFLAGS += $(include_flags)
export CLASP_DEBUG_LINKFLAGS += $(lib_flags)
export CLASP_RELEASE_CXXFLAGS += $(include_flags)
export CLASP_RELEASE_LINKFLAGS += $(lib_flags)

export BINDIR ?= $(CLASP_INTERNAL_BUILD_TARGET_DIR)/$(EXECUTABLE_DIR)
export EXECS ?= $(CLASP_INTERNAL_BUILD_TARGET_DIR)/Contents/execs/

export PATH := $(LLVM_BIN_DIR):$(PATH)
export PATH := $(CLASP_HOME)/src/common:$(PATH)
export PATH := $(BOOST_BUILD_INSTALL)/bin:$(PATH)
export PATH := $(BINDIR):$(PATH)

ifneq ($(CXXFLAGS),)
  export USE_CXXFLAGS := cxxflags=$(CXXFLAGS)
endif

ifeq ($(NO_COLOR),)
TPUT = $(call pathsearch,tput)
ifneq ($(TPUT),)
  COLOR_GREEN = $(shell $(TPUT) setaf 2 2>/dev/null)
  COLOR_RESET = $(shell $(TPUT) sgr0    2>/dev/null)
endif
endif
define varprint
	@echo -e "$(COLOR_GREEN)$(strip $(1))$(COLOR_RESET): $($(strip $(1)))"
endef

all:
	$(MAKE) print-config
	$(MAKE) submodules
	$(MAKE) asdf
	$(MAKE) boost_build
	$(MAKE) boehm
	$(MAKE) copy-lisp
	$(MAKE) boehm-cxx
	$(MAKE) min-boehm
	$(MAKE) full-boehm
	$(MAKE) cclasp-boehm
	$(MAKE) cclasp-boehm-addons
	$(MAKE) executable-symlinks
	echo Clasp is now built
.PHONY: all

mps-build:
	(cd src/main; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/mps/release gc=mps release clasp_install )
	(cd src/main; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/mps/debug gc=mps debug clasp_install )
	$(MAKE) -C src/main link-min-mps
.PHONY: mps-build

boot:
	$(MAKE) submodules
	$(MAKE) asdf
	$(MAKE) boost_build
	$(MAKE) boehm
	$(MAKE) -C src/main boehmdc-release-cxx
	$(MAKE) executable-symlinks
	$(MAKE) -C src/main min-boehmdc
	$(MAKE) -C src/main bclasp-boehmdc-bitcode
	$(MAKE) -C src/main bclasp-boehmdc-fasl
	$(MAKE) -C src/main bclasp-boehmdc-addons
.PHONY: boot

boot-mps-interface:
	$(MAKE) boot
	$(MAKE) -C src/main mps-interface
#	$(MAKE) -C src/main bclasp-boehmdc
#	$(MAKE) -C src/main bclasp-boehmdc-addons
.PHONY: boot-mps-interface

clasp-libraries:
	(cd src/gctools; $(BJAM) link=$(LINK) program=clasp gctools install-lib)
.PHONY: clasp-libraries

executable-symlinks:
	install -d $(BINDIR)
	ln -sf ../Contents/execs/boehm/release/bin/clasp $(BINDIR)/clasp_boehm_o
	ln -sf ../Contents/execs/boehmdc/release/bin/clasp $(BINDIR)/clasp_boehmdc_o
	ln -sf ../Contents/execs/mps/release/bin/clasp $(BINDIR)/clasp_mps_o
	ln -sf ../Contents/execs/boehm/debug/bin/clasp $(BINDIR)/clasp_boehm_d
	ln -sf ../Contents/execs/boehmdc/debug/bin/clasp $(BINDIR)/clasp_boehmdc_d
	ln -sf ../Contents/execs/mps/debug/bin/clasp $(BINDIR)/clasp_mps_d
.PHONY: executable-symlinks

# Ensure that Make does not delete intermediate files in any rule
.SECONDARY:

submodule-libatomic: .gitmodules
	-git submodule update --init src/boehm/libatomic_ops
.PHONY: submodule-libatomic

libatomic-setup: libatomic-configure
.PHONY: libatomic-setup

$(LIBATOMIC_OPS_SOURCE_DIR)/configure: submodule-libatomic
	-(cd $(LIBATOMIC_OPS_SOURCE_DIR); autoreconf -vif)
	-(cd $(LIBATOMIC_OPS_SOURCE_DIR); automake --add-missing )
libatomic-autoconf: $(LIBATOMIC_OPS_SOURCE_DIR)/configure
.PHONY: libatomic-autoconf

$(LIBATOMIC_OPS_SOURCE_DIR)/Makefile: libatomic-autoconf
	install -d $(CLASP_APP_RESOURCES_LIB_COMMON_DIR);
	(cd $(LIBATOMIC_OPS_SOURCE_DIR); \
		export ALL_INTERIOR_PTRS=1; \
		CFLAGS="-DUSE_MMAP -g" \
		./configure --enable-shared=yes --enable-static=yes --enable-handle-fork --enable-cplusplus --prefix=$(CLASP_APP_RESOURCES_LIB_COMMON_DIR);)
libatomic-configure: $(LIBATOMIC_OPS_SOURCE_DIR)/Makefile
.PHONY: libatomic-configure

$(CLASP_APP_RESOURCES_LIB_COMMON_DIR)/libatomic_ops.a: libatomic-configure
	(cd $(LIBATOMIC_OPS_SOURCE_DIR); $(MAKE) -j$(PJOBS) | tee _libatomic_ops.log)
	(cd $(LIBATOMIC_OPS_SOURCE_DIR); $(MAKE) -j$(PJOBS) install | tee _libatomic_ops_install.log)
libatomic-compile: $(CLASP_APP_RESOURCES_LIB_COMMON_DIR)/libatomic_ops.a
.PHONY: libatomic-compile

boehm-setup: boehm-configure
.PHONY: boehm-setup

submodule-boehm: .gitmodules
	-git submodule update --init src/boehm/bdwgc
.PHONY: submodule-boehm

$(BOEHM_SOURCE_DIR)/configure: submodule-boehm
	-(cd $(BOEHM_SOURCE_DIR); autoreconf -vif)
	-(cd $(BOEHM_SOURCE_DIR); automake --add-missing )
boehm-autoconf: $(BOEHM_SOURCE_DIR)/configure
.PHONY: boehm-autoconf

$(BOEHM_SOURCE_DIR)/Makefile: boehm-autoconf libatomic-compile
	(cd $(BOEHM_SOURCE_DIR); \
		export ALL_INTERIOR_PTRS=1; \
                CC=$(BOEHM_CC) \
		CXX=$(BOEHM_CXX) \
                CFLAGS="-DUSE_MMAP -g" \
		PKG_CONFIG_PATH=$(CLASP_APP_RESOURCES_LIB_COMMON_DIR)/lib/pkgconfig/ \
		./configure --enable-shared=yes --enable-static=yes --enable-handle-fork --enable-cplusplus --prefix=$(CLASP_APP_RESOURCES_LIB_COMMON_DIR) --with-libatomic-ops=yes;)
boehm-configure: $(BOEHM_SOURCE_DIR)/Makefile
.PHONY: boehm-configure

$(CLASP_APP_RESOURCES_LIB_COMMON_DIR)/lib/libgc.a: boehm-configure
	(cd $(BOEHM_SOURCE_DIR); $(MAKE) -j$(PJOBS) | tee _boehm.log)
	(cd $(BOEHM_SOURCE_DIR); $(MAKE) -j$(PJOBS) install | tee _boehm_install.log)
boehm-compile: $(CLASP_APP_RESOURCES_LIB_COMMON_DIR)/lib/libgc.a
.PHONY: boehm-compile

boehm: boehm-compile
.PHONY: boehm

submodule-asdf: .gitmodules
	-git submodule update --init src/lisp/modules/asdf
.PHONY: submodule-asdf

submodule-sicl: .gitmodules
	-git submodule update --init src/lisp/kernel/contrib/sicl
.PHONY: submodule-sicl

copy-lisp: boost_build submodule-asdf submodule-sicl
	(cd src/lisp; $(BJAM) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp gc=boehm bundle )
.PHONY: copy-lisp

$(CLASP_APP_EXECS)/boehm/release/bin/clasp: boost_build boehm
	(cd src/main; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/$(VARIANT) gc=boehm $(VARIANT) clasp_install )
boehm-cxx: $(CLASP_APP_EXECS)/boehm/release/bin/clasp
.PHONY: boehm-cxx

$(CLASP_APP_RESOURCES_DIR)/lisp/build/system/min-boehm/image.o: boehm-cxx
	$(MAKE) -C src/main min-boehm
min-boehm: $(CLASP_APP_RESOURCES_DIR)/lisp/build/system/min-boehm/image.o
.PHONY: min-boehm

$(CLASP_APP_RESOURCES_DIR)/lisp/build/system/full-boehm/image.o: min-boehm
	$(MAKE) -C src/main bclasp-boehm-bitcode
	$(MAKE) -C src/main bclasp-boehm-fasl
full-boehm: $(CLASP_APP_RESOURCES_DIR)/lisp/build/system/full-boehm/image.o
.PHONY: full-boehm

$(CLASP_APP_RESOURCES_DIR)/lisp/build/system/cclasp-boehm/image.o: full-boehm
	$(MAKE) -C src/main cclasp-from-bclasp-boehm-bitcode
	$(MAKE) -C src/main cclasp-boehm-fasl
cclasp-boehm: $(CLASP_APP_RESOURCES_DIR)/lisp/build/system/cclasp-boehm/image.o
.PHONY: cclasp-boehm

CCLASP_BOEHM_MODULES = $(CLASP_APP_RESOURCES_DIR)/lisp/build/system/cclasp-boehm/modules
$(CCLASP_BOEHM_MODULES)/serve-event/serve-event.o $(CCLASP_BOEHM_MODULES)/asdf/asdf.o: cclasp-boehm
	$(MAKE) -C src/main cclasp-boehm-addons
cclasp-boehm-addons: $(CCLASP_BOEHM_MODULES)/serve-event/serve-event.o $(CCLASP_BOEHM_MODULES)/asdf/asdf.o
.PHONY: cclasp-boehm-addons

boehm-release-clbind:
	(cd src/clbind; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/release gc=boehm release clasp-clbind-install)
.PHONY: boehm-release-clbind

boehm-release-clbind-a:
	(cd src/clbind; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/release gc=boehm release clasp-clbind-install -a)
.PHONY: boehm-release-clbind-a

boehm-debug-clbind:
	(cd src/clbind; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/debug gc=boehm debug clasp-clbind-install)
.PHONY: boehm-debug-clbind

boehm-debug-clbind-a:
	(cd src/clbind; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehm/debug gc=boehm debug clasp-clbind-install -a)
.PHONY: boehm-debug-clbind-a

boehmdc-release-clbind:
	(cd src/clbind; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/boehmdc/release gc=boehmdc release clasp-clbind-install)
.PHONY: boehmdc-release-clbind

mps-clbind:
	(cd src/clbind; $(BUILD) -j$(PJOBS) toolset=$(TOOLSET) link=$(LINK) program=clasp --prefix=$(CLASP_APP_EXECS)/mps/$(VARIANT) gc=mps $(VARIANT) clasp-clbind-install)
.PHONY: mps-clbind

boehm-clean:
	install -d $(BOEHM_SOURCE_DIR)
	-(cd $(BOEHM_SOURCE_DIR); $(MAKE) clean )
	if test -e $(LIBATOMIC_OPS_CONFIGURE); then rm $(LIBATOMIC_OPS_CONFIGURE) ; fi
	if test	-e $(BDWGC_CONFIGURE); then rm $(BDWGC_CONFIGURE) ; fi
.PHONY: boehm-clean

pump:
	(cd src/core; $(MAKE) pump)
	(cd src/clbind; $(MAKE) pump)
.PHONY: pump

submodules:
	$(MAKE) submodules-boehm
	$(MAKE) submodules-mps
.PHONY: submodules

submodules-boehm:
	-git submodule update --init tools/boost_build
	-git submodule update --init src/boehm/libatomic_ops
	-git submodule update --init src/boehm/bdwgc
	-git submodule update --init src/lisp/kernel/contrib/sicl
	-git submodule update --init src/lisp/modules/asdf
	-git submodule update --init tools/boost_build
#	-(cd src/lisp/modules/asdf; git checkout master; git pull origin master)
.PHONY: submodules-boehm

submodules-mps:
	-git submodule update --init src/mps
.PHONY: submodules-mps

asdf: src/lisp/modules/asdf/build/asdf.lisp
.PHONY: asdf

src/lisp/modules/asdf/build/asdf.lisp: 
	(cd src/lisp/modules/asdf; $(MAKE))

#
# Tell ASDF where to find the SICL/Code/Cleavir systems - the final // means search subdirs
#
#export CL_SOURCE_REGISTRY = $(shell echo `pwd`/src/lisp/kernel/contrib/sicl/Code/Cleavir//):$(shell echo `pwd`/src/lisp/kernel/contrib/slime//)

#
# When developing, set the CLASP_LISP_SOURCE_DIR environment variable
# to tell clasp to use the development source directly rather than the
# stuff in the clasp build target directory.  This saves us the trouble of
# constantly having to copy the lisp sources to the target directory.
export DEV_CLASP_LISP_SOURCE_DIR := $(shell pwd)/src/lisp

devemacs:
	@echo This shell sets up environment variables like BJAM
	@echo as they are defined when commands execute within the makefile
	(CLASP_LISP_SOURCE_DIR=$(DEV_CLASP_LISP_SOURCE_DIR) $(DEVEMACS))
.PHONY: devemacs

devemacs_no_clasp_lisp_source_dir:
	@echo This shell sets up environment variables like BJAM
	@echo as they are defined when commands execute within the makefile
	$(DEVEMACS)
.PHONY: devemacs_no_clasp_lisp_source_dir

devshell:
	@echo This shell sets up environment variables like BJAM
	@echo as they are defined when commands execute within the makefile
	(CLASP_LISP_SOURCE_DIR=$(DEV_CLASP_LISP_SOURCE_DIR) bash)
.PHONY: devshell


devshell-telemetry:
	@echo This shell sets up environment variables like BJAM
	@echo as they are defined when commands execute within the makefile
	(CLASP_LISP_SOURCE_DIR=$(DEV_CLASP_LISP_SOURCE_DIR); export CLASP_MPS_CONFIG="32 32 16 80 32 80"; export CLASP_TELEMETRY_FILE=/tmp/clasp.tel; export CLASP_TELEMETRY_MASK=3; bash)
.PHONY: devshell-telemetry


submodule-boost: .gitmodules
	-git submodule update --init tools/boost_build

boost_build: $(BOOST_BUILD_INSTALL)/bin/bjam
.PHONY: boost_build

$(BOOST_BUILD_INSTALL)/bin/bjam: submodule-boost
	install -d $(BOOST_BUILD_INSTALL)
	(cd $(BOOST_BUILD_SOURCE_DIR); export BOOST_BUILD_PATH=`pwd`; ./bootstrap.sh; ./b2 toolset=clang install --prefix=$(BOOST_BUILD_INSTALL) --ignore-site-config)

clean:
	git submodule sync
	$(MAKE) boehm-clean
	(cd src/main; rm -rf bin bundle)
	(cd src/core; rm -rf bin bundle)
	(cd src/gctools; rm -rf bin bundle)
	(cd src/llvmo; rm -rf bin bundle)
	(cd src/asttooling; rm -rf bin bundle)
	(cd src/cffi; rm -rf bin bundle)
	(cd src/clbind; rm -rf bin bundle)
	(cd src/sockets; rm -rf bin bundle)
	(cd src/serveEvent; rm -rf bin bundle)
ifneq ($(CLASP_INTERNAL_BUILD_TARGET_DIR),)
	install -d $(CLASP_INTERNAL_BUILD_TARGET_DIR)
	-(find $(CLASP_INTERNAL_BUILD_TARGET_DIR) -type f -print0 | xargs -0 rm -f)
endif
.PHONY: clean

setup-cleavir:
	clasp_boehm_o -f bclasp -l src/lisp/kernel/cleavir/setup-cclasp-build.lisp -e "(core:quit)"
.PHONY: setup-cleavir

pull-sicl-master:
	(cd src/lisp/kernel/contrib/sicl; git pull origin master)
	$(MAKE) setup-cleavir
.PHONY: pull-sicl-master

mps-submodule:
	git submodule add -b dev/2014-08-18/non-incremental  https://github.com/Ravenbrook/mps-temporary ./src/mps
.PHONY: mps-submodule


asdf-submodule:
	git submodule add --name updatedAsdf https://github.com/drmeister/asdf.git ./src/lisp/kernel/asdf
.PHONY: asdf-submodule

dump-local-config:
	cat $(CLASP_HOME)/local.config
.PHONY: dump-local-config

print-config:
	$(info >> Makefile Configuration:)
	$(call varprint, CLASP_HOME)
	$(call varprint, EXTERNALS_CLASP_DIR)
	$(call varprint, LLVM_CONFIG)
	$(call varprint, TARGET_OS)
	$(call varprint, ADDRESS-MODEL)
	$(call varprint, LINK)
	$(call varprint, PJOBS)
	$(call varprint, LLVM_CONFIG_DEBUG)
	$(call varprint, LLVM_CONFIG_RELEASE)
	$(call varprint, LLVM_BIN_DIR)
	$(call varprint, CLANG_BIN_DIR)
	$(call varprint, GIT_COMMIT)
	$(call varprint, CLASP_VERSION)
	$(call varprint, CLASP_INTERNAL_BUILD_TARGET_DIR)
	$(call varprint, LIBATOMIC_OPS_SOURCE_DIR)
	$(call varprint, BOEHM_SOURCE_DIR)
	$(call varprint, BOOST_BUILD_SOURCE_DIR)
	$(call varprint, BOOST_BUILD_INSTALL)
	$(call varprint, BJAM)
	$(call varprint, BUILD)
	$(call varprint, CLASP_APP_EXECS)
	$(call varprint, CLASP_APP_RESOURCES_DIR)
	$(call varprint, CLASP_APP_RESOURCES_LIB_COMMON_DIR)
	$(call varprint, CLASP_DEBUG_LLVM_LIB_DIR)
	$(call varprint, CLASP_RELEASE_LLVM_LIB_DIR)
	$(call varprint, CLASP_DEBUG_CXXFLAGS)
	$(call varprint, CLASP_DEBUG_LINKFLAGS)
	$(call varprint, CLASP_RELEASE_CXXFLAGS)
	$(call varprint, CLASP_RELEASE_LINKFLAGS)
	$(call varprint, VARIANT)
	$(call varprint, TOOLSET)
	$(call varprint, DEVEMACS)
	$(call varprint, PYTHON2)
	$(call varprint, EXECUTABLE_DIR)
	$(call varprint, BINDIR)
	$(call varprint, EXECS)
	$(call varprint, PATH)
	$(call varprint, USE_CXXFLAGS)
.PHONY: print-config

clang-format:
	git ls-files src/ include/ \
	| perl -ne 'chomp;print "$$_\n" if -f $$_ and (/\.[hc][hcp]?p?$$/) and !-l and !m#^include/.+/generated#;' \
	| xargs -P$(PJOBS) -n1 --verbose clang-format -i
.PHONY: clang-format
