# these targets do not generate any files so they are.. .PHONY
.PHONY: clean clean-all install uninstall flatpak-test-development setup-flatpak all

# Install to /usr unless otherwise specified, such as `make PREFIX=/app`
PREFIX=/usr

# What to run to install various files
INSTALL=install
# Run to install the actual binary
INSTALL_PROGRAM=$(INSTALL)
# Run to install application data, with differing permissions
INSTALL_DATA=$(INSTALL) -m 644

# Directories into which to install the various files
bindir=$(DESTDIR)$(PREFIX)/bin
sharedir=$(DESTDIR)$(PREFIX)/share

# Build the application (release)
target/release/helloworld: src
	@echo **** SHAREDIR=$(sharedir)/helloworld  ****
	SHAREDIR=$(sharedir)/helloworld cargo build --release

# Install onto the system
install: target/release/helloworld
	mkdir -p $(bindir)
	$(INSTALL_PROGRAM) target/release/helloworld $(bindir)/me.bcow.HelloWorld
	mkdir -p $(sharedir)/helloworld
	$(INSTALL_DATA) helloworld.txt $(sharedir)/helloworld/helloworld.txt

# Remove an existing install from the system
uninstall :
	rm -f $(bindir)/me.bcow.HelloWorld
	rm -f $(sharedir)/me.bcow.HelloWorld/helloworld.txt

# Build a Flatpak package
flatpak-development: target/release/helloworld
	mkdir -p flatpak-development
	flatpak-builder --repo flatpak-development-repo flatpak-development data/me.bcow.HelloWorld-development.yaml

# remove development build files
clean-dev:
	rm -rf flatpak-development/ flatpak-development-repo/

# Remove supplemental build files
clean: clean-dev
	rm -rf .flatpak-builder/

clean-all: clean
	rm -rf target/
	rm *.flatpak

# Test the flatpak package install locally
flatpak-test-development:
	flatpak-builder --user --install flatpak-development data/me.bcow.HelloWorld-development.yaml
	@echo
	@echo ===========
	@echo
	flatpak run me.bcow.HelloWorld
	@echo
	@echo ===========
	@echo
	flatpak --user uninstall --assumeyes me.bcow.HelloWorld

flatpak-bundle-development: flatpak-development
	flatpak build-bundle flatpak-development-repo helloworld-development.flatpak me.bcow.HelloWorld

# Helper for setting up the env for building flatpak packages
setup-flatpak:
	flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install --user --assumeyes flathub org.freedesktop.Platform//21.08 org.freedesktop.Sdk//21.08
	flatpak install --user --assumeyes flathub org.freedesktop.Sdk.Extension.rust-stable//21.08

all: setup-flatpak flatpak-development flatpak-bundle-development

# eof
