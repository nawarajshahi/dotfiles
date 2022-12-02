# Source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# When a command was run that spanned multiple lines, merge that into a single
# history entry for the purposes of looking back.
shopt -s cmdhist

# Ensure we append to the history file rather than replacing it
shopt -s histappend

# Enable globstar matching
shopt -s globstar

# Disable the XON/XOFF flow control completely (Ctrl-Q/Ctrl-S). Damn this is an
# annoying legacy feature...
if [ -t 0 ]; then
  stty -ixon
fi

# Fuck this command auto search bull shit
unset command_not_found_handle
unset LESSOPEN
unset SSH_ASKPASS

# Hidden environment variable to disable telemetry tracking in the Azure CLI
export AZURE_CORE_COLLECT_TELEMETRY=0

# Likely not adopted by anyone, but for the apps that do I definitely want to opt-out
# https://consoledonottrack.com/
export DO_NOT_TRACK=1

export DOTFILES_DIR="$HOME/.dotfiles"
export EDITOR="vim"

# NetworkManager is absolute trash and doesn't allow you to set these, so we
# have to fallback on env variables
export RES_OPTIONS="edns0 trust-ad"

# If we're running interactively (such as through rsync, sftp etc) don't
# execute the rest of the setup code.
if [[ $- != *i* ]]; then
  return
fi

# Source all executable files that live the system-specific folder
for FILE in $HOME/.dotfiles/system-specific/*.sh; do
  if [ -x "$FILE" ]; then
    source $FILE
  fi
done

alias gb='git branch --sort=-committerdate | head -n 20'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset - %G? %C(yellow)%d%Creset%s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=rfc'
alias gr='git fetch && git rebase origin/master'
alias gs='git status'
alias gt='git log --tags --simplify-by-decoration --pretty="format:%ai %d"'

alias dig='dig +nocmd +noall +answer'
alias gdb='gdb -q'
alias vi='vim'

export PATH="$HOME/.dotfiles/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

# You know what I really need? An archive of every bash command I ever run...
if [ ! -f "${HOME}/.dotfiles/bash-histories/.archive_created" ]; then
  mkdir -p "${HOME}/.dotfiles/bash-histories"
  touch "${HOME}/.dotfiles/bash-histories/.archive_created"
fi

export HISTCONTROL="ignoreboth"
export HISTIGNORE="ls:bg:fg:history"
export HISTSIZE=-1
export HISTTIMEFORMAT="%F %T "

# Some color definitions
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 5)
RST=$(tput sgr0)

function personal_ps1_prompt() {
  #local __bat_status="\$(${DOTFILES_DIR}/helpers/battery_status.sh)"
  local __bat_status=""
  #local __exit_status="\$(${DOTFILES_DIR}/helpers/exit_status.sh $?)"
  local __exit_status=""
  #local __git="\[${BLUE}\]\$(${DOTFILES_DIR}/helpers/git-ps1-wrapper.sh)\[${RST}\]"
  local __path="\$(${DOTFILES_DIR}/helpers/shortdir.sh)"
  local __user_host="[\u@\h]"

  if [ -n "${TMUX_PANE}" ]; then
    echo "$__bat_status$__exit_status $__path$__git \\$"
  else
    echo "$__bat_status$__exit_status $__user_host $__path$__git \\$"
  fi
}

function setup_prompt {
  export PS1="$(personal_ps1_prompt) "

  # Don't expose more than path through the window title...
  export PROMPT_COMMAND='echo -en "\033]0;${PWD/#${HOME}/\~}\a"'
}

setup_prompt

source $HOME/.dotfiles/helpers/gpg-agent.sh

[[ -f "$HOME/.cargo/env" ]] && source $HOME/.cargo/env
[[ -f "$HOME/.rvm/scripts/rvm" ]] && source $HOME/.rvm/scripts/rvm
