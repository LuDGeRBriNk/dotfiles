# 🌌 Arch Linux + Hyprland Dotfiles

![Arch Linux](https://img.shields.io/badge/OS-Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/WM-Hyprland-00A896?style=for-the-badge&logo=wayland&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Zsh_&_P10k-00A896?style=for-the-badge&logo=zsh&logoColor=white)
![Manager](https://img.shields.io/badge/Manager-GNU_Stow-1793D1?style=for-the-badge&logo=gnu&logoColor=white)

A strictly modular, logically structured approach to system configuration. This repository is designed to bridge the gap between managing headless servers and deploying a fully hardware-accelerated desktop environment.

## 🏗️ Architecture

This repository uses **GNU Stow** to manage symlinks, split into distinct modules to prevent configuration bleed.

* **`/base`**: The foundational TTY module. Contains `zsh`, `nvim`, CLI tools, and core aliases. Designed to be safely deployed on any headless server.
* **`/hyprland`**: The graphical module. Contains Wayland compositor settings, `waybar`, `kitty`, and GUI app configurations. 

## 🚀 Installation

### 1. Clone the repository
```bash
git clone git@github.com:LuDGeRBriNk/dotfiles.git ~/dotfiles
cd ~/dotfiles
