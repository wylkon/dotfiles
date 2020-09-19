#!/usr/bin/env bash

libs=(apps binaries brew dotfiles fonts npm rubygems tools)

# Help text
source ./lib/help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    run_help
    exit
fi

source ./lib/utils
# Source the necessary files and helper scripts
for i in "${libs[@]}"; do
    source ./lib/"$i"
done

if array_contains "$1" "${libs[@]}"; then

    seek_confirmation "Do you want to install $1"

    if is_confirmed; then
        run_"$1"
    fi
    exit
else
  seek_confirmation "Do you want to proceed with the installation"

  if ! is_confirmed; then
    exit
  fi
fi

sudo -v
sudo chown -R $USER /usr/local/

git pull

# Before relying on Homebrew, check that packages can be compiled
if ! type_exists 'gcc'; then
    e_error "The XCode Command Line Tools must be installed first."
    printf "  run 'xcode-select --install' and follow the instructions\n"
    printf "  Then run this setup script again.\n"
    exit 1
fi

#     __  __                     __
#    / / / /___  ____ ___  ___  / /_  ________ _      __
#   / /_/ / __ \/ __ `__ \/ _ \/ __ \/ ___/ _ \ | /| / /
#  / __  / /_/ / / / / / /  __/ /_/ / /  /  __/ |/ |/ /
# /_/ /_/\____/_/ /_/ /_/\___/_.___/_/   \___/|__/|__/


# Check for Homebrew
if ! type_exists 'brew'; then
    e_process "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

#  ______     ______     __  __
# /\___  \   /\  ___\   /\ \_\ \
# \/_/  /__  \ \___  \  \ \  __ \
#   /\_____\  \/\_____\  \ \_\ \_\
#   \/_____/   \/_____/   \/_/\/_/


if [ ! -e ~/.oh-my-zsh ]; then
  e_process "Define ZSH as default"
  chsh -s /bin/zsh

  e_process "Installing Oh-my-zsh"
  /bin/bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

e_process "Installing Homebrew packages"
run_brew

#     ____        __
#    / __ \__  __/ /_  __  __
#   / /_/ / / / / __ \/ / / /
#  / _, _/ /_/ / /_/ / /_/ /
# /_/ |_|\__,_/_.___/\__, /
#                   /____/

e_process "Installing Rbenv and Gems"
run_rubygems

#     _   ______  __  ___
#    / | / / __ \/  |/  /
#   /  |/ / /_/ / /|_/ /
#  / /|  / ____/ /  / /
# /_/ |_/_/   /_/  /_/
#

e_process "Installing NPM Packages"
run_npm

#    ______            __
#   /_  __/___  ____  / /____
#    / / / __ \/ __ \/ / ___/
#   / / / /_/ / /_/ / (__  )
#  /_/  \____/\____/_/____/
#

if ! type_exists 'push'; then
	e_process "Installing git-friendly"
	sudo bash < <( curl https://raw.githubusercontent.com/jamiew/git-friendly/master/install.sh)
fi

e_success "All packages have been installed"


#        __      __  _____ __
#   ____/ /___  / /_/ __(_) /__  _____
#  / __  / __ \/ __/ /_/ / / _ \/ ___/
# / /_/ / /_/ / /_/ __/ / /  __(__  )
# \__,_/\____/\__/_/ /_/_/\___/____/


# Ask before potentially overwriting files
seek_confirmation "Overwrite your existing dotfiles"

if is_confirmed; then
    # Symlink all necessary files

    run_dotfiles

    e_success "All files have been symlinked"

else
    e_error "This step is required.  When you're ready, run this script to start up again"
fi

#      ____  _                  _
#     / __ )(_)___  ____ ______(_)__  _____
#    / __  / / __ \/ __ `/ ___/ / _ \/ ___/
#   / /_/ / / / / / /_/ / /  / /  __(__  )
#  /_____/_/_/ /_/\__,_/_/  /_/\___/____/

seek_confirmation "Install useful binaries?"

if is_confirmed; then
    # Symlink all necessary files

    run_binaries

    e_success "All binaries installed to /usr/local/bin"``
fi


#    ____  _____    _  __    ___
#   / __ \/ ___/   | |/ /   /   |  ____  ____  _____
#  / / / /\__ \    |   /   / /| | / __ \/ __ \/ ___/
# / /_/ /___/ /   /   |   / ___ |/ /_/ / /_/ (__  )
# \____//____/   /_/|_|  /_/  |_/ .___/ .___/____/
#                              /_/   /_/

# Ask installing OS X Applications?
seek_confirmation "Do you want to install Mac OS X Apps and stuff"

if is_confirmed; then

    e_process "Installing Mac OS X Applications"
    run_apps

    e_process "Installing Mac OS X fonts"
    run_fonts

    e_success "All Mac OS X Applications have been installed"

    e_warning "Please consider using cask commands for Updating/Upgrading or Uninstalling a Mac OS X Application"
fi

e_success "Your Mac is ready to rock! 💥"
