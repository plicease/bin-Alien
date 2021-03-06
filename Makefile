WGET=wget
RM=rm -f
MV=mv
CP=cp
MKDIR=mkdir -p
PERL=perl
PATCH=patch

BITS=
HOST_ARCH=i586-mingw32msvc

BUILD_ROOT=$(shell pwd)
BUILD_ARCH=x86_64-unknown-linux

BISON_VERSION=3.0.4
BISON_SRC_TAR=$(BUILD_ROOT)/src/bison-$(BISON_VERSION).tar.gz
BISON_CONFIGURE=--prefix=$(BISON_BUILD_PREFIX) \
	--host=$(HOST_ARCH)                     \
	--build=$(BUILD_ARCH)
BISON_BIN_TAR=$(BUILD_ROOT)/dist/bison-$(BISON_VERSION)-$(HOST_ARCH).tar.gz
BISON_INSTALLER=$(BUILD_ROOT)/dist/bison-$(BISON_VERSION)-$(HOST_ARCH)-setup.exe
BISON_INSTALLER_OPTIONS=                       \
        $(BITS)                                 \
	--appname=bison				\
	--orgname='Perl Alien::Base Team'	\
	--version=$(BISON_VERSION)		\
	--nsi=$(BUILD_ROOT)/dist/bison-$(BISON_VERSION)-$(HOST_ARCH)-setup.nsi                 \
	--description='Portable Foreign Function Interface Library'
BISON_BUILD_PREFIX=$(BUILD_ROOT)/local/bison/$(BISON_VERSION)-$(BUILD_ARCH)/bison
BISON_SRC_ROOT=http://ftp.gnu.org/gnu/bison

LIBFFI_VERSION=3.2.1
LIBFFI_SRC_TAR=$(BUILD_ROOT)/src/libffi-$(LIBFFI_VERSION).tar.gz
LIBFFI_CONFIGURE=--prefix=$(LIBFFI_BUILD_PREFIX) \
	--disable-shared --with-pic             \
	--host=$(HOST_ARCH)                     \
	--build=$(BUILD_ARCH)
LIBFFI_BIN_TAR=$(BUILD_ROOT)/dist/libffi-$(LIBFFI_VERSION)-$(HOST_ARCH).tar.gz
LIBFFI_INSTALLER=$(BUILD_ROOT)/dist/libffi-$(LIBFFI_VERSION)-$(HOST_ARCH)-setup.exe
LIBFFI_INSTALLER_OPTIONS=                       \
        $(BITS)                                 \
	--appname=libffi			\
	--orgname='Perl Alien::Base Team'	\
	--version=$(LIBFFI_VERSION)		\
	--nsi=$(BUILD_ROOT)/dist/libffi-$(LIBFFI_VERSION)-$(HOST_ARCH)-setup.nsi                 \
	--description='Portable Foreign Function Interface Library'
LIBFFI_BUILD_PREFIX=$(BUILD_ROOT)/local/libffi/$(LIBFFI_VERSION)-$(BUILD_ARCH)/libffi
LIBFFI_SRC_ROOT=ftp://sourceware.org/pub/libffi

LIBARCHIVE_VERSION=3.1.2
LIBARCHIVE_SRC_TAR=$(BUILD_ROOT)/src/libarchive-$(LIBARCHIVE_VERSION).tar.gz
LIBARCHIVE_CONFIGURE=--prefix=$(LIBARCHIVE_BUILD_PREFIX) \
	--without-xml2                        \
	--host=$(HOST_ARCH)                   \
	--build=$(BUILD_ARCH)
LIBARCHIVE_BIN_TAR=$(BUILD_ROOT)/dist/libarchive-$(LIBARCHIVE_VERSION)-$(HOST_ARCH).tar.gz
LIBARCHIVE_INSTALLER=$(BUILD_ROOT)/dist/libarchive-$(LIBARCHIVE_VERSION)-$(HOST_ARCH)-setup.exe
LIBARCHIVE_INSTALLER_OPTIONS=                   \
        $(BITS)                                 \
	--appname=libarchive			\
	--orgname='Perl Alien::Base Team'	\
	--version=$(LIBARCHIVE_VERSION)		\
	--icon=resource/icon.ico                \
	--nsi=$(BUILD_ROOT)/dist/libarchive-$(LIBARCHIVE_VERSION)-$(HOST_ARCH)-setup.nsi                 \
	--description='Multi-format archive and compression library'
LIBARCHIVE_BUILD_PREFIX=$(BUILD_ROOT)/local/libarchive/$(LIBARCHIVE_VERSION)-$(BUILD_ARCH)/libarchive
LIBARCHIVE_SRC_ROOT=http://www.libarchive.org/downloads

all: win32 win64

win32:
	$(MAKE) libarchive libffi bison HOST_ARCH=i586-mingw32msvc

win64:
	$(MAKE) libarchive libffi bison HOST_ARCH=x86_64-w64-mingw32 BITS=-64

libarchive: $(LIBARCHIVE_BIN_TAR) $(LIBARCHIVE_INSTALLER)

$(LIBARCHIVE_INSTALLER): $(LIBARCHIVE_BIN_TAR)
	$(PERL) script/create_installer.pl $(LIBARCHIVE_BIN_TAR) --setup=$(LIBARCHIVE_INSTALLER) $(LIBARCHIVE_INSTALLER_OPTIONS)

$(LIBARCHIVE_BIN_TAR): $(LIBARCHIVE_SRC_TAR)
	$(MKDIR) build
	$(RM) -r build/libarchive-$(LIBARCHIVE_VERSION)
	cd build ; tar zxf $(LIBARCHIVE_SRC_TAR)
	cd build/libarchive-$(LIBARCHIVE_VERSION) ; ./configure $(LIBARCHIVE_CONFIGURE) && $(MAKE) V=1 && rm -rf $(LIBARCHIVE_BUILD_PREFIX) && $(MAKE) V=1 install
	$(MKDIR) $(BUILD_ROOT)/dist
	$(PERL) script/update_pkgconfig.pl $(LIBARCHIVE_BUILD_PREFIX)
	$(PERL) script/install_doco.pl build/libarchive-$(LIBARCHIVE_VERSION)/COPYING  \
	                               build/libarchive-$(LIBARCHIVE_VERSION)/README   \
	                               build/libarchive-$(LIBARCHIVE_VERSION)/NEWS     $(LIBARCHIVE_BUILD_PREFIX)
	cd $(LIBARCHIVE_BUILD_PREFIX)/.. ; tar zcvf $(LIBARCHIVE_BIN_TAR) libarchive

$(LIBARCHIVE_SRC_TAR):
	$(WGET) $(LIBARCHIVE_SRC_ROOT)/libarchive-$(LIBARCHIVE_VERSION).tar.gz -O $(LIBARCHIVE_SRC_TAR).tmp
	$(MV) $(LIBARCHIVE_SRC_TAR).tmp $(LIBARCHIVE_SRC_TAR)

libffi: $(LIBFFI_BIN_TAR) $(LIBFFI_INSTALLER)

$(LIBFFI_INSTALLER): $(LIBFFI_BIN_TAR)
	$(PERL) script/create_installer.pl $(LIBFFI_BIN_TAR) --setup=$(LIBFFI_INSTALLER) $(LIBFFI_INSTALLER_OPTIONS)

$(LIBFFI_BIN_TAR): $(LIBFFI_SRC_TAR)
	$(MKDIR) build
	$(RM) -r build/libffi-$(LIBFFI_VERSION)
	cd build ; tar zxf $(LIBFFI_SRC_TAR)
	cd build/libffi-$(LIBFFI_VERSION) ; ./configure $(LIBFFI_CONFIGURE) && $(MAKE) V=1 && rm -rf $(LIBFFI_BUILD_PREFIX) && $(MAKE) V=1 install
	$(MKDIR) $(BUILD_ROOT)/dist
	$(PERL) script/update_pkgconfig.pl $(LIBFFI_BUILD_PREFIX)
	$(PERL) script/install_doco.pl build/libffi-$(LIBFFI_VERSION)/LICENSE   \
	                               build/libffi-$(LIBFFI_VERSION)/README    $(LIBFFI_BUILD_PREFIX)
	cd $(LIBFFI_BUILD_PREFIX)/.. ; tar zcvf $(LIBFFI_BIN_TAR) libffi

$(LIBFFI_SRC_TAR):
	$(WGET) $(LIBFFI_SRC_ROOT)/libffi-$(LIBFFI_VERSION).tar.gz -O $(LIBFFI_SRC_TAR).tmp
	$(MV) $(LIBFFI_SRC_TAR).tmp $(LIBFFI_SRC_TAR)

bison: $(BISON_BIN_TAR) $(BISON_INSTALLER)

$(BISON_INSTALLER): $(BISON_BIN_TAR)
	$(PERL) script/create_installer.pl $(BISON_BIN_TAR) --setup=$(BISON_INSTALLER) $(BISON_INSTALLER_OPTIONS)

$(BISON_BIN_TAR): $(BISON_SRC_TAR)
	$(MKDIR) build
	$(RM) -r build/bison-$(BISON_VERSION)
	cd build ; tar zxf $(BISON_SRC_TAR)
	cd build/bison-$(BISON_VERSION) ; patch -p1 < ../../src/bison-3.0.4.diff
	cd build/bison-$(BISON_VERSION) ; ./configure $(BISON_CONFIGURE) && $(MAKE) V=1 && rm -rf $(BISON_BUILD_PREFIX) && $(MAKE) V=1 install
	$(MKDIR) $(BUILD_ROOT)/dist
	$(PERL) script/install_doco.pl build/bison-$(BISON_VERSION)/COPYING   \
	                               build/bison-$(BISON_VERSION)/NEWS      \
	                               build/bison-$(BISON_VERSION)/README    $(BISON_BUILD_PREFIX)
	cd $(BISON_BUILD_PREFIX)/.. ; tar zcvf $(BISON_BIN_TAR) bison

$(BISON_SRC_TAR):
	$(WGET) $(BISON_SRC_ROOT)/bison-$(BISON_VERSION).tar.gz -O $(BISON_SRC_TAR).tmp
	$(MV) $(BISON_SRC_TAR).tmp $(BISON_SRC_TAR)

src: $(BISON_SRC_TAR) $(LIBFFI_SRC_TAR) $(LIBARCHIVE_SRC_TAR)

clean:
	$(RM) src/*.tmp
	$(RM) -r local
	$(RM) -r build

realclean: clean
	$(RM) src/*.tar.gz dist/*
