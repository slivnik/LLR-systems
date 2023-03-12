all:
	$(MAKE) -C src all

distclean:
	find . -name '*~' -delete
	find tests -name 'example-*' -exec $(MAKE) -C {} distclean \;
	$(MAKE) -C src distclean
