#!/bin/bash

# trap '' 2

function echo_sleep(){
  echo -e "$1\n"
  sleep 1
}

updated_system=false
function update_system() {
  if [ "$updated_system" = false ] ; then
    echo_sleep "Update system"
    updated_system=true
    sudo apt update && sudo apt upgrade -y && sudo apt autoclean -y && sudo apt autoremove -y
  fi
}

function configure_git(){
  echo_sleep "Configuring git..."
  command -v git >/dev/null 2>&1 || (update_system && sudo apt install git -y)

  read -p "What is your git name: " git_name
  read -p "What is your git email: " git_email

  git config --global user.name $git_name
  git config --global user.email $git_email
  git config --global core.editor vim
  git config --global color.ui true
  git config --global core.autocrlf true
  
  # View abbreviated SHA, description, and history graph of the latest 20 commits
	git config --global alias.l "log --pretty=oneline -n 20 --graph --abbrev-commit"
	git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

  # View the current working tree status using the short format
	git config --global alias.s "status -s"
  # Show the diff between the latest commit and the current state
	git config --global alias.d "!(git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat)"

  # Switch to a branch, creating it if necessary
	# git config --global alias.go "!f(){ git checkout -b \"$1\" 2> /dev/null || git checkout \"$1\"; }; f"

  # Show verbose output about tags, branches or remotes
	git config --global alias.tags "tag -l"
	git config --global alias.branches "branch -a"
	git config --global alias.remotes "remote -v"

	# List aliases
	git config --global alias.aliases "config --get-regexp alias"

  if [ ! -e ~/.ssh/github ]; then
    ssh-keygen -b 4096 -f ~/.ssh/github -t rsa -C $git_email
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/github
  fi

  if [ ! -e ~/.ssh/config ]; then
    cat > ~/.ssh/config <<EOF
Host *
    ServerAliveInterval 60

Host github.com
    HostName github.com
    IdentityFile ~/.ssh/github
EOF
  fi

  echo
}

PS3="Choose an option: "
menu_options=("Configure All" "Configure git" "Quit")
while true; do
  echo "Let's configure your system"
  select opt in "${menu_options[@]}"; do
    case $REPLY in
      1) check_update; break ;;
      2) configure_git; break ;;
      3) break 2 ;;
      *)
        echo -e "\nInvalid option"
        read -rsn1 -p "Press any key to continue" >&2
        echo -e "\n"
        break;
    esac
  done
done

echo "Bye bye!"