ROOTDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OUTPUTDIR ?= $(shell readlink -f "$(ROOTDIR)/../man/man1")
MANPAGE_TARGETS = $(patsubst %.pod,%.1.gz,$(wildcard *.pod))

all: $(MANPAGE_TARGETS)

install:
	mkdir -p $(OUTPUTDIR)
	$(foreach target,$(MANPAGE_TARGETS),install -m 644 $(target) $(OUTPUTDIR)/$(target);)
	$(foreach target,$(MANPAGE_TARGETS),rm $(target);)

%.1.gz : %.pod
	pod2man \
		--center="tools" \
		--release="" \
		$< | gzip -c > $@
