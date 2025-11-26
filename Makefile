.PHONY: server laptop permissions clean help

# Default target (does nothing)
.DEFAULT_GOAL := help

# Set executable permissions on scripts
permissions:
	chmod +x *.sh

# Server setup: global install + global link
server: permissions
	./install_deps_global.sh
	./link_dotfiles_global.sh

# Laptop setup: global + laptop install + global + laptop link
laptop: permissions
	./install_deps_global.sh
	./install_deps_laptop.sh
	./link_dotfiles_global.sh
	./link_dotfiles_laptop.sh

# Clean up (remove symlinks)
clean:
	rm -f ~/.bashrc ~/.zshrc ~/.gitconfig ~/.ssh/config

# Show available targets
help:
	@echo "Available targets:"
	@echo "  server      - Install global deps and link profiles (for servers)"
	@echo "  laptop      - Install all deps and link all dotfiles (for laptop)"
	@echo "  permissions - Make scripts executable"
	@echo "  clean       - Remove dotfile symlinks"
	@echo "  help        - Show this help message"
