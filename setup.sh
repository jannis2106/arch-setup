#!/bin/sh

# ---------------------
# Check root privileges 
# ---------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi


# -------------------
# Set up default user
# -------------------
read -p "Create a new default user? (y/n) " yn

if [[ $yn =~ ^[Yy]$ ]]; then
  read -p "Enter name for user: " USERNAME
  read -s -p "Enter password for user ${USERNAME}: " PASSWORD
  echo
  read -s -p "Confirm password: " PASSWORD_CONFIRM
  echo

  if [[ $PASSWORD != $PASSWORD_CONFIRM ]]; then
    echo "Passwords do not match!"
    exit
  fi

  # create user
  useradd -m -G wheel -s /bin/bash ${USERNAME}

  # set user password
  echo "${USERNAME}:${PASSWORD}" | chpasswd

  # give user sudo privileges (update visudo)
  echo "%wheel ALL=(ALL) ALL" >> etc/sudoers
  echo "User ${USERNAME} created and grated full permissions!"
fi


# -------------------
# Install basic tools
# -------------------
read -p "Install basic tools (git, vim, ...)? (y/n ) " yn

if [[ $yn =~ ^[Yy]$ ]]; then
  # update all packages first
  pacman -Syuu
  pacman -S git base-devel bat exa vim wget figlet
  echo "Installed basic tools!"
fi


# ----------------------
# Install yay AUR-helper
# ----------------------
read -p "Install yay? (y/n) " yn

if [[ $yn =~ ^[Yy]$ ]]; then
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  cd ..
  rm -rf yay
  echo "Installed yay!"
fi


# -------------------------
# Install zsh and oh-my-zsh
# -------------------------
read -p "Install zsh and oh-my-zsh? (y/n) " yn

if [[ $yn =~ ^[Yy]$ ]]; then
  pacman -S zsh
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

  # download custom .zshrc
  wget "https://github.com/jannis2106/arch-setup/blob/main/.zshrc" -O .zshrc

  pacman -S zsh-autosuggestions
  echo "zsh and oh-my-zsh installed!"
fi

echo "Script Done!"
exit
