#!/bin/bash

# List of packages to install
packages=(
	# Tools
	bat
	# chezmoi
	fish
	fzf
	# git
	ripgrep
	vim
	zoxide

	# Applications
	vivaldi	
)

# List of post-installation commands to run
post_commands=(
	# "chezmoi init --apply CodeTex"
	"chsh -s /usr/bin/fish"
	"echo 'Post-installation commands completed!'"
)

install_packages() {
	echo "Starting package installation..."
	for pkg in "${packages[@]}"; do
		echo "Installing $pkg..."
		yay -S --noconfirm "$pkg"
		if [ $? -ne 0 ]; then
			echo "Failed to install $pkg"
			exit 1
		fi
	done
	echo "All packages installed successfully!"
}

run_post_commands() {
	echo "Running post-installation commands..."
	for cmd in "${post_commands[@]}"; do
		echo "Executing: $cmd"
		eval "$cmd"
		if [ $? -ne 0 ]; then
			echo "Command failed: $cmd"
			exit 1
		fi
	done
}

install_packages
run_post_commands

echo "Setup completed"
