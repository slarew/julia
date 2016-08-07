JULIAHOME := $(abspath ../../..)
include $(JULIAHOME)/Make.inc

# Build and bundle Julia (release XOR debug) as a Darwin/Apple framework
# usage: make O=<builddir> framework

default: framework

# The codesigning identity on Darwin.
# Used with `codesign -s $(DARWIN_CODESIGN_KEYCHAIN_IDENTITY) $file`.
# The default "-" makes an ad-hoc signature.
DARWIN_CODESIGN_KEYCHAIN_IDENTITY ?= -

# The prefix for all code sign identifiers.
DARWIN_CODESIGN_ID_BASE ?= org.julialang.julia

# The codesign id for the ui/repl (also embedded in Info.plist).
darwin_codesign_id_julia_ui := $(DARWIN_CODESIGN_ID_BASE).ui
# The prefix for all deps.
darwin_codesign_id_julia_deps := $(DARWIN_CODESIGN_ID_BASE).deps

# framework directory structure targets
framework_destdirs := $(sort $(bindir) $(libdir) $(private_libdir) $(datarootdir) $(docdir) $(mandir) $(man1dir) $(includedir) $(sysconfdir) $(addprefix $(DESTDIR)$(prefix)/,$(framework_currver) $(framework_headers) $(framework_headers)/julia $(framework_documentation) $(framework_resources) $(framework_frameworks) $(framework_modules) $(framework_helpers) $(framework_currver)/lib))

# symlink targets
framework_current_symlinks := $(addprefix $(DESTDIR)$(prefix)/$(framework_directory)/,$(FRAMEWORK_NAME) Headers Documentation Resources Frameworks Modules Helpers)
framework_version_symlink := $(DESTDIR)$(prefix)/$(framework_versions)/Current

# list of julia private libs for the framework
framework_private_libs = $(sort $(filter-out libpcre2-posix.1.dylib libpcre2-posix.dylib,\
  $(shell for suffix in $(JL_PRIVATE_LIBS) ; do \
    for lib in $(build_libdir)/lib$${suffix}*.dylib; do \
      echo $$(basename $$lib); \
   done; done)))

# targets:

$(framework_destdirs):
	mkdir -p $@
$(framework_current_symlinks): | $(framework_destdirs)
	ln -s -f Versions/Current/$(notdir $@) $@
$(framework_version_symlink): | $(framework_destdirs)
	ln -s -f $(FRAMEWORK_VERSION) $@

$(DESTDIR)$(prefix)/$(framework_currver)/bin: | $(framework_destdirs)
	ln -s -f Helpers $@
$(DESTDIR)$(prefix)/$(framework_currver)/lib/libjulia$(JULIA_LIBSUFFIX).$(SOMAJOR).$(SOMINOR).dylib: | $(framework_destdirs)
	ln -s -f ../$(FRAMEWORK_NAME) $@
$(DESTDIR)$(prefix)/$(framework_currver)/lib/libjulia$(JULIA_LIBSUFFIX).$(SOMAJOR).dylib: | $(framework_destdirs)
	ln -s -f ../$(FRAMEWORK_NAME) $@
$(DESTDIR)$(prefix)/$(framework_currver)/lib/libjulia$(JULIA_LIBSUFFIX).dylib: | $(framework_destdirs)
	ln -s -f ../$(FRAMEWORK_NAME) $@
$(DESTDIR)$(prefix)/$(framework_currver)/libexec: | $(framework_destdirs)
	ln -s -f Helpers $@
$(DESTDIR)$(prefix)/$(framework_currver)/share: | $(framework_destdirs)
	ln -s -f Resources $@
$(DESTDIR)$(prefix)/$(framework_currver)/include: | $(framework_destdirs)
	ln -s -f Headers $@
$(DESTDIR)$(prefix)/$(framework_currver)/etc: | $(framework_destdirs)
	ln -s -f Resources $@

hier_symlinks: \
	$(DESTDIR)$(prefix)/$(framework_currver)/bin \
	$(DESTDIR)$(prefix)/$(framework_currver)/lib/libjulia$(JULIA_LIBSUFFIX).$(SOMAJOR).$(SOMINOR).dylib \
	$(DESTDIR)$(prefix)/$(framework_currver)/lib/libjulia$(JULIA_LIBSUFFIX).$(SOMAJOR).dylib \
	$(DESTDIR)$(prefix)/$(framework_currver)/lib/libjulia$(JULIA_LIBSUFFIX).dylib \
	$(DESTDIR)$(prefix)/$(framework_currver)/libexec \
	$(DESTDIR)$(prefix)/$(framework_currver)/share \
	$(DESTDIR)$(prefix)/$(framework_currver)/include \
	$(DESTDIR)$(prefix)/$(framework_currver)/etc

$(DESTDIR)$(prefix)/$(framework_infoplist): | $(framework_destdirs)
	/usr/libexec/PlistBuddy -x -c "Clear dict" $@
	/usr/libexec/PlistBuddy -x -c "Add :CFBundleName string $(FRAMEWORK_NAME)" $@
	/usr/libexec/PlistBuddy -x -c "Add :CFBundleExecutable string $(FRAMEWORK_NAME)" $@
	/usr/libexec/PlistBuddy -x -c "Add :CFBundleIdentifier string org.julialang.julia.lib" $@
	#TODO: reflect dev/rc#/commithash in CFBundleVersion
	/usr/libexec/PlistBuddy -x -c "Add :CFBundleVersion string $(JULIA_MAJOR_VERSION).$(JULIA_MINOR_VERSION).$(JULIA_PATCH_VERSION)" $@
	/usr/libexec/PlistBuddy -x -c "Add :CFBundleShortVersionString string $(JULIA_MAJOR_VERSION).$(JULIA_MINOR_VERSION).$(JULIA_PATCH_VERSION)" $@
	/usr/libexec/PlistBuddy -x -c "Add :CFBundleSignature string ???" $@
	/usr/libexec/PlistBuddy -x -c "Add :CFBundlePackageType string FMWK" $@
	/usr/libexec/PlistBuddy -x -c "Add :CFBundleInfoDictionaryVersion string 6.0" $@
	/usr/libexec/PlistBuddy -x -c "Add :NSHumanReadableCopyright string \"Copyright © 2009-2017 Julia project contributors (https://github.com/JuliaLang/julia/contributors). See LICENSE.md.\"" $@

# from top-level Makefile:
define stringreplace
	$(build_depsbindir)/stringreplace $$(strings -t x - $1 | grep '$2' | awk '{print $$1;}') '$3' 255 "$(call cygpath_w,$1)"
endef


framework: $(DESTDIR)$(prefix)/$(framework_infoplist) | $(framework_current_symlinks) $(framework_version_symlink) $(framework_destdirs) hier_symlinks
ifneq ($(DARWIN_FRAMEWORK),1)
	$(error Darwin framework is not enabled. Please set DARWIN_FRAMEWORK=1)
endif

	$(MAKE) -C $(BUILDROOT) $(JULIA_BUILD_MODE) $(build_depsbindir)/stringreplace $(BUILDROOT)/doc/_build/html/en/index.html

	# Add julia exe
	$(INSTALL_M) $(JULIA_EXECUTABLE) $(DESTDIR)$(prefix)/$(framework_helpers)/julia
	$(INSTALL_NAME_CHANGE_CMD) @rpath/libjulia$(JULIA_LIBSUFFIX).dylib @rpath/$(FRAMEWORK_NAME) $(DESTDIR)$(prefix)/$(framework_helpers)/julia
	$(JULIAHOME)/contrib/mac/framework/delete-all-rpaths.sh $(DESTDIR)$(prefix)/$(framework_helpers)/julia
	install_name_tool -add_rpath @executable_path/$(libdir_rel) $(DESTDIR)$(prefix)/$(framework_helpers)/julia

	# Add libjulia
	$(INSTALL_M) $(build_shlibdir)/libjulia$(JULIA_LIBSUFFIX).$(SOMAJOR).$(SOMINOR).dylib $(DESTDIR)$(prefix)/$(framework_dylib)
	$(INSTALL_NAME_CMD)$(framework_dylib) $(DESTDIR)$(prefix)/$(framework_dylib)
	$(JULIAHOME)/contrib/mac/framework/delete-all-rpaths.sh $(DESTDIR)$(prefix)/$(framework_dylib)
	install_name_tool -add_rpath @loader_path/Frameworks $(DESTDIR)$(prefix)/$(framework_dylib)

	# Copy system image
	$(INSTALL_M) $(build_private_libdir)/sys$(JULIA_LIBSUFFIX).$(SHLIB_EXT) $(DESTDIR)$(prefix)/$(framework_frameworks)
	$(INSTALL_NAME_CHANGE_CMD) @rpath/libjulia$(JULIA_LIBSUFFIX).dylib @rpath/$(FRAMEWORK_NAME) $(DESTDIR)$(prefix)/$(framework_frameworks)/sys$(JULIA_LIBSUFFIX).dylib
	$(JULIAHOME)/contrib/mac/framework/delete-all-rpaths.sh $(DESTDIR)$(prefix)/$(framework_frameworks)/sys$(JULIA_LIBSUFFIX).dylib
	install_name_tool -add_rpath @loader_path/.. $(DESTDIR)$(prefix)/$(framework_frameworks)/sys$(JULIA_LIBSUFFIX).dylib

	# Add private libs
	for lib in $(addprefix $(build_shlibdir)/,$(framework_private_libs)); do \
	  $(INSTALL_M) $$lib $(DESTDIR)$(prefix)/$(framework_frameworks); \
	done
	$(JULIAHOME)/contrib/mac/framework/delete-all-rpaths.sh $(DESTDIR)$(prefix)/$(framework_frameworks)/*

	$(JULIAHOME)/contrib/fixup-libgfortran.sh $(DESTDIR)$(prefix)/$(framework_frameworks)

	# Add headers
	$(INSTALL_F) $(build_includedir)/julia/* $(DESTDIR)$(prefix)/$(framework_headers)/julia
	sed -e 's/<Julia/<$(FRAMEWORK_NAME)/' $(JULIAHOME)/contrib/mac/framework/Julia.h > $(DESTDIR)$(prefix)/$(framework_headers)/$(FRAMEWORK_NAME).h

	# Copy documentation
	cp -R -L $(build_docdir)/* $(DESTDIR)$(prefix)/$(framework_documentation)
	cp -R -L $(BUILDROOT)/doc/_build/html $(DESTDIR)$(prefix)/$(framework_documentation)

	# Copy in all .jl source
	cp -R -L $(build_datarootdir)/julia $(DESTDIR)$(prefix)/$(framework_resources)
	cp -R -L $(JULIAHOME)/base/* $(DESTDIR)$(prefix)/$(framework_resources)/julia/base
	cp -R -L $(JULIAHOME)/test/* $(DESTDIR)$(prefix)/$(framework_resources)/julia/test
	# Copy in system image build script
	$(INSTALL_M) $(JULIAHOME)/contrib/build_sysimg.jl $(DESTDIR)$(prefix)/$(framework_resources)/julia
	# Copy in standalone julia-config script
	$(INSTALL_M) $(JULIAHOME)/contrib/julia-config.jl $(DESTDIR)$(prefix)/$(framework_resources)/julia
	# Remove perf suite
	rm -rf $(DESTDIR)$(prefix)/$(framework_resources)/julia/test/perf
	# Remove various files which should not be installed
	rm $(DESTDIR)$(prefix)/$(framework_resources)/julia/base/version_git.sh
	find $(DESTDIR)$(prefix)/$(framework_directory) -type f -name '.DS_Store' -o -type d -name '__MACOSX' -o -type f -name '.git*' -o -type f -name Makefile -print0 | xargs -0 rm -rf
	# Copy in beautiful new man page
	$(INSTALL_F) $(build_man1dir)/julia.1 $(DESTDIR)$(man1dir)/

	# Update JL_SYSTEM_IMAGE_PATH if $(private_libdir_rel) != $(build_private_libdir_rel)
ifneq ($(private_libdir_rel),$(build_private_libdir_rel))
	# Overwrite JL_SYSTEM_IMAGE_PATH in julia library
	$(call stringreplace,$(DESTDIR)$(prefix)/$(framework_dylib),sys$(JULIA_LIBSUFFIX).dylib$$,$(private_libdir_rel)/sys$(JULIA_LIBSUFFIX).dylib)
endif

	# Include Julia's license info
	$(INSTALL_F) $(JULIAHOME)/LICENSE.md $(DESTDIR)$(prefix)/$(framework_resources)

ifeq ($(JULIA_BUILD_MODE),debug)
	# Leave a visible trace file indicating a debug build.
	touch $(DESTDIR)$(prefix)/$(framework_resources)/DEBUGBUILD
endif

	# Add the module map file.
	sed -e 's/Julia/$(FRAMEWORK_NAME)/' $(JULIAHOME)/contrib/mac/framework/module.modulemap > $(DESTDIR)$(prefix)/$(framework_modules)/module.modulemap

	# Make sure EUID:EGID owns the framework
	chown -R $$(id -un):$$(id -gn) $(DESTDIR)$(prefix)/$(framework_directory)

	# ad-hoc codesigning
	#NB: must be the last lines of the recipe, else signature may be invalidated.

	# Codesign should look at the embedded Info.plist to get the signing identifier.
	# See JLDFLAGS in Make.inc for Darwin platform and Info.plist target in ui/Makefile.
	codesign -s $(DARWIN_CODESIGN_KEYCHAIN_IDENTITY) -v $(DESTDIR)$(prefix)/$(framework_helpers)/julia

	# Append the library name to the base codesigning id.
	for file in $(DESTDIR)$(prefix)/$(framework_frameworks)/*.dylib* ; do \
		if [ -f "$$file" -a ! -L "$$file" -a -w "$$file" -a -x "$$file" ]; then \
			idsuffix=$$(basename $${file%%.dylib*}) ; \
			codesign -s $(DARWIN_CODESIGN_KEYCHAIN_IDENTITY) -v -i $(darwin_codesign_id_julia_deps).$${idsuffix} -f $$file ; \
		fi \
	done

	# Sign the (current version) framework bundle.
	codesign -s $(DARWIN_CODESIGN_KEYCHAIN_IDENTITY) -v $(DESTDIR)$(prefix)/$(framework_currver)


.PHONY: framework hier_symlinks
