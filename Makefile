# Makefile for disk-mark-me

# Default prefix for installation.
# Users can override this: make PREFIX=/usr/local install
PREFIX ?= $(HOME)/.local
BIN_DIR := $(PREFIX)/bin

# Name of the script file
SCRIPT_NAME := disk-mark-me

.PHONY: all install uninstall update help examples

all: help

help:
	@echo "Makefile for $(SCRIPT_NAME)"
	@echo ""
	@echo "Usage:"
	@echo "  make install          Install $(SCRIPT_NAME) to $(BIN_DIR)."
	@echo "  make update           Alias for 'make install'."
	@echo "  make uninstall        Uninstall $(SCRIPT_NAME) from $(BIN_DIR)."
	@echo ""
	@echo "  make examples         Show example usages of $(SCRIPT_NAME)."
	@echo "  make help             Show this help message."
	@echo ""
	@echo "Current script source:      ./$(SCRIPT_NAME)"
	@echo "User installation prefix: $(PREFIX) (Override with 'make PREFIX=/your/path install')"
	@echo "Installation directory:   $(BIN_DIR)"

install: $(BIN_DIR)/$(SCRIPT_NAME)
	@echo ""
	@echo "✅ $(SCRIPT_NAME) installed successfully to $(BIN_DIR)/$(SCRIPT_NAME)."
	@echo "⚠️ IMPORTANT: Ensure '$(BIN_DIR)' is in your system's PATH."
	@echo "   You might need to start a new shell session or source your shell profile"
	@echo "   (e.g., ~/.bashrc, ~/.zshrc, ~/.profile) for the command to be available."

update: install

# Rule to install the script
# This depends on the local script file being present.
$(BIN_DIR)/$(SCRIPT_NAME): ./$(SCRIPT_NAME)
	@echo "Installing $(SCRIPT_NAME) to $(BIN_DIR)..."
	@mkdir -p $(BIN_DIR)
	@cp ./$(SCRIPT_NAME) $(BIN_DIR)/$(SCRIPT_NAME)
	@chmod +x $(BIN_DIR)/$(SCRIPT_NAME)

uninstall:
	@if [ -f "$(BIN_DIR)/$(SCRIPT_NAME)" ]; then \
		echo "Uninstalling $(SCRIPT_NAME) from $(BIN_DIR)..."; \
		rm -f $(BIN_DIR)/$(SCRIPT_NAME); \
		echo "$(SCRIPT_NAME) uninstalled."; \
	else \
		echo "$(SCRIPT_NAME) is not installed in $(BIN_DIR) (or PREFIX is different from installation)."; \
	fi

examples:
	@echo "Example usages for $(SCRIPT_NAME):"
	@echo ""
	@echo "  # Run a default benchmark (1 round, 1GiB file) on /mnt/sdcard:"
	@echo "  $(SCRIPT_NAME) -t /mnt/sdcard"
	@echo ""
	@echo "  # Run 3 rounds using a 512MiB test file on /media/my_usb:"
	@echo "  $(SCRIPT_NAME) -t /media/my_usb -s 512m -r 3"
	@echo ""
	@echo "  # Run 5 rounds, 2GiB file, with verbose output:"
	@echo "  $(SCRIPT_NAME) -t /tmp -s 2g -r 5 -v"
	@echo ""
	@echo "  # Display help for the script:"
	@echo "  $(SCRIPT_NAME) -h"

# No 'clean' target needed as there are no build artifacts for a single script.
