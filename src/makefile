

#
# Targets are subAll, subInstall, subClean
#
sa subAll subInstall subClean subClassTree sct subBundle sb subMeta sm sad:

SRC-SUB-DIRS = gctools core cffi clbind asttooling llvmo serveEvent sockets

sub-prebuild:
	$(MAKE) -C gctools/ $@
	$(MAKE) -C core/ $@
	$(MAKE) -C clbind/ $@
	$(MAKE) -C llvmo/ $@
	$(MAKE) -C asttooling/ $@
	$(MAKE) -C serveEvent/ $@
	$(MAKE) -C sockets/ $@




tags:
	$(CTAGS_BIN) -e -R .



allTags at:
	echo no ctags -R


cleanBins:
	-find . -name 'bin' -exec rm -rf {} \;

mps-submodule:
	git submodule add -b dev/2014-08-18/non-incremental https://github.com/Ravenbrook/mps-temporary mps


