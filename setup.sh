#!/bin/bash

# ---------------------
# Check root privileges 
# ---------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
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
    exit 1
  fi

  # create user
  useradd -m -G wheel -s /bin/bash ${USERNAME}

  # set user password
  echo "${USERNAME}:${PASSWORD}" | chpasswd

  # give user sudo privileges (update visudo)
  echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
  echo "User ${USERNAME} created and granted full permissions!"
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

  # check if USERNAME is set
  if [ -z "$USERNAME" ]; then
    read -p "Enter username to build yay with: " TARGET_USER
  else
    TARGET_USER="$USERNAME"
  fi

  # check if user exists
  if ! id "$TARGET_USER" >/dev/null 2>&1; then
    echo "User '$TARGET_USER' does not exist! Aborting zsh setup."
    exit 1
  fi

  # check if yay is already installed
  if command -v yay >/dev/null 2>&1; then
    echo "yay is already installed!"
  else
    USER_HOME=$(eval echo "~$TARGET_USER")
  
    sudo -u "$TARGET_USER" bash -c "
      cd $USER_HOME &&
      git clone https://aur.archlinux.org/yay.git &&
      cd yay &&
      makepkg -si --noconfirm &&
      cd .. &&
      rm -rf yay
    "
    
    echo "Installed yay!"
  fi
fi


# -------------------------
# Install zsh and oh-my-zsh
# -------------------------
read -p "Install zsh and oh-my-zsh? (y/n) " yn

if [[ $yn =~ ^[Yy]$ ]]; then

  # check if USERNAME is set
  if [ -z "$USERNAME" ]; then
    read -p "Enter username, for who to install oh-my-zsh: " TARGET_USER
  else
    TARGET_USER="$USERNAME"
  fi

  # check if user exists
  if ! id "$TARGET_USER" >/dev/null 2>&1; then
    echo "User '$TARGET_USER' does not exist! Aborting zsh setup."
    exit 1
  fi

  # get home directory of user
  USER_HOME=$(eval echo "~$TARGET_USER")

  # install zsh
  pacman -S zsh

  # install oh-my-zsh as user
  sudo -iu "$TARGET_USER" sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # download custom .zshrc as user
  sudo -iu "$TARGET_USER" wget "https://raw.githubusercontent.com/jannis2106/arch-setup/refs/heads/main/.zshrc" -O .zshrc

  # ensure correct ownership
  chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/.zshrc"  

  # set zsh as default shell
  chsh -s /bin/zsh "$TARGET_USER"

  # install plugins
  pacman -S zsh-autosuggestions
  
  echo "zsh and oh-my-zsh installed!"
fi

echo "Script Done!"
exit 1
