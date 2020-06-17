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
}

function configure_curl(){
  echo_sleep "Configuring curl..."
  
  if [ ! -e ~/.curlrc ]; then
    cat > ~/.curlrc <<EOF
# Disguise as IE 9 on Windows 7.
user-agent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"

# When following a redirect, automatically set the previous URL as referer.
referer = ";auto"

# Wait 60 seconds before timing out.
connect-timeout = 60
EOF
  fi
}

function configure_vim(){
  echo_sleep "Configuring vim..."
  command -v vim >/dev/null 2>&1 || (update_system && sudo apt install vim -y)

  cat > ~/.vimrc <<EOF
" Turn on syntax highlighting.
syntax on

colorscheme desert

" Show line numbers
set number

" Encoding
set encoding=utf-8

" Status bar
set laststatus=2

" Display different types of white spaces.
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.
EOF
}

function configure_bash() {
  cat > ~/.bash_aliases <<EOF
#!/usr/bin/env bash

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Shortcuts
alias d="cd ~/Descargas"
alias p="cd ~/dev"

alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# Enable aliases to be sudo’ed
alias sudo='sudo '
EOF

  source ~/.bash_aliases
}

PS3="Choose an option: "
menu_options=("Configure All" "Configure git" "Configure Curl" "Configure Vim" "Configure Bash" "Quit")
while true; do
  echo -e "\nLet's configure your system"
  select opt in "${menu_options[@]}"; do
    case $REPLY in
      1) configure_git && configure_curl && configure_vim; break ;;
      2) configure_git; break ;;
      3) configure_curl; break;;
      4) configure_vim; break;;
      5) configure_bash; break;;
      6) break 2 ;;
      *)
        echo -e "\nInvalid option"
        read -rsn1 -p "Press any key to continue" >&2
        echo -e "\n"
        break;
    esac
  done
done

echo "Bye bye!"