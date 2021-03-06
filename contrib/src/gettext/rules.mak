# gettext
GETTEXT_VERSION=0.19.6
GETTEXT_URL=$(GNU)/gettext/gettext-$(GETTEXT_VERSION).tar.gz

PKGS += gettext
ifneq ($(filter gnu%,$(subst -, ,$(HOST))),)
# GNU platform should have gettext (?)
PKGS_FOUND += gettext
endif

$(TARBALLS)/gettext-$(GETTEXT_VERSION).tar.gz:
	$(call download_pkg,$(GETTEXT_URL),gettext)

.sum-gettext: gettext-$(GETTEXT_VERSION).tar.gz

gettext: gettext-$(GETTEXT_VERSION).tar.gz .sum-gettext
	$(UNPACK)
	$(MOVE)

DEPS_gettext = iconv $(DEPS_iconv)

GETTEXT_CONF = \
	--disable-relocatable \
	--disable-java \
	--disable-native-java \
	--without-emacs
ifdef HAVE_WIN32
GETTEXT_CONF += --disable-threads
endif

.gettext: gettext
	cd $< && $(HOSTVARS) ./configure $(HOSTCONF) $(GETTEXT_CONF)
ifndef HAVE_ANDROID
	cd $< && $(MAKE) install
else
	cd $< && $(MAKE) -C gettext-runtime install
	cd $< && $(MAKE) -C gettext-tools/intl
	cd $< && $(MAKE) -C gettext-tools/misc install
	cd $< && $(MAKE) -C gettext-tools/m4 install
endif
ifdef HAVE_MACOSX
	# detect libintl correctly in configure for static library
	sed -i.orig  's/$$LIBS $$LIBINTL/$$LIBS $$LIBINTL $$INTL_MACOSX_LIBS/' "$(PREFIX)"/share/aclocal/gettext.m4
endif
	touch $@
