PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

.PHONY: install uninstall test

install:
	install -d "$(BINDIR)"
	install -m 0755 bin/wtcp "$(BINDIR)/wtcp"

uninstall:
	rm -f "$(BINDIR)/wtcp"

test:
	bash test/test_wtcp.sh
