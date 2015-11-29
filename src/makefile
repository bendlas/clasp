

#
# Targets are subAll, subInstall, subClean
#
sa subAll subInstall subClean subClassTree sct subBundle sb subMeta sm sad:
.PHONY: sa subAll subInstall subClean subClassTree sct subBundle sb subMeta sm sad

SRC-SUB-DIRS = gctools core cffi clbind asttooling llvmo serveEvent sockets

sub-prebuild:
	$(MAKE) -C gctools/ $@
	$(MAKE) -C core/ $@
	$(MAKE) -C clbind/ $@
	$(MAKE) -C llvmo/ $@
	$(MAKE) -C asttooling/ $@
	$(MAKE) -C serveEvent/ $@
	$(MAKE) -C sockets/ $@
.PHONY: sub-prebuild




tags:
	$(CTAGS_BIN) -e -R .
.PHONY: tags



allTags at:
	echo no ctags -R
.PHONY: allTags at


cleanBins:
	-find . -name 'bin' -exec rm -rf {} \;
.PHONY: cleanBins

mps-submodule:
	git submodule add -b dev/2014-08-18/non-incremental https://github.com/Ravenbrook/mps-temporary mps
.PHONY: mps-submodule


