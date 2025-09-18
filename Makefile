.PHONY: run install link permissions clean help

# Default target
run: permissions install link

# Set executable permissions on scripts
permissions:
	chmod +x *.sh

# Install dependencies
install:
	./install_deps.sh

# Link dotfiles
link:
	./link_dotfiles.sh

# Clean up (remove symlinks)
clean:
	rm -f ~/.bashrc ~/.zshrc ~/.gitconfig ~/.ssh/config

# Show available targets
help:
	@echo "Available targets:"
	@echo "  run         - Set permissions, install deps, and link dotfiles (default)"
	@echo "  permissions - Make scripts executable"
	@echo "  install     - Install dependencies"
	@echo "  link        - Link dotfiles"
	@echo "  clean       - Remove dotfile symlinks"
	@echo "  help        - Show this help message"
