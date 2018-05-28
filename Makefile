.PHONY: install run-example

LIBDIR ?= /usr/lib

install: class.sh
	install class.sh -m 644 "$(LIBDIR)/cla.sh"

run-example: example.sh
	./example.sh
