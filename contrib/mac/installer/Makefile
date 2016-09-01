JULIAHOME := $(abspath ../../..)
include $(JULIAHOME)/Make.inc

# Build a product archive with Darwin framework for macOS Installer

# The codesiging identity for the product archive (the .pkg installer).
DARWIN_CODESIGN_PRODUCT_ARCHIVE_KEYCHAIN_IDENTITY  ?= -

default: frameworkinstaller

$(DESTDIR)$(prefix)/$(framework_dylib):
	$(MAKE) -C $(JULIAHOME)/contrib/mac/framework framework

$(BUILDROOT)/$(FRAMEWORK_NAME)-framework.pkg: $(DESTDIR)$(prefix)/$(framework_dylib)
	pkgbuild \
		--component $(DESTDIR)$(prefix)/$(framework_directory) \
		--install-location /Library/Frameworks \
		--version $(JULIA_MAJOR_VERSION).$(JULIA_MINOR_VERSION).$(JULIA_PATCH_VERSION) \
		$@

$(BUILDROOT)/$(FRAMEWORK_NAME).dist: $(JULIAHOME)/contrib/mac/installer/Julia.dist
	sed -e 's/MINVERSION/$(MACOSX_VERSION_MIN)/g' -e 's/FRAMEWORK_NAME/$(FRAMEWORK_NAME)/g' $< > $@

.INTERMEDIATE: $(BUILDROOT)/$(FRAMEWORK_NAME)-framework.pkg $(BUILDROOT)/$(FRAMEWORK_NAME).dist

$(BUILDROOT)/$(FRAMEWORK_NAME)-$(JULIA_VERSION).pkg: $(BUILDROOT)/$(FRAMEWORK_NAME)-framework.pkg $(BUILDROOT)/$(FRAMEWORK_NAME).dist $(JULIAHOME)/contrib/mac/installer/resources
	productbuild \
		--package-path $(BUILDROOT) \
		--resources ./resources \
		--distribution $(BUILDROOT)/$(FRAMEWORK_NAME).dist \
		$@

frameworkinstaller: $(BUILDROOT)/$(FRAMEWORK_NAME)-$(JULIA_VERSION).pkg

signframeworkinstaller: $(BUILDROOT)/$(FRAMEWORK_NAME)-$(JULIA_VERSION).pkg
	productsign --sign $(DARWIN_CODESIGN_PRODUCT_ARCHIVE_KEYCHAIN_IDENTITY) $< $<.signed
	mv $<.signed $<

clean:
	-rm $(BUILDROOT)/$(FRAMEWORK_NAME)-$(JULIA_VERSION).pkg

.PHONY: frameworkinstaller signframeworkinstaller
