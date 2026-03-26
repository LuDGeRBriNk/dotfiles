#!/bin/bash

# Define the target directory outside of the dotfiles repo
VENV_DIR="$HOME/.local/share/nvim/venv"

echo "Setting up Neovim Python Virtual Environment..."

# 1. Create the directory and the venv
mkdir -p "$HOME/.local/share/nvim"
python -m venv "$VENV_DIR"

# 2. Install the required packages for Gemini and Neovim
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install pynvim google-generativeai

echo "Done! Neovim venv created at $VENV_DIR"
