# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

umask 002

# Update path to include Android SDK tools
if [ -d ~/.local/share/android-sdk/cmdline-tools/latest/bin ]; then
  export PATH="$PATH:$HOME/.local/share/android-sdk/cmdline-tools/latest/bin"
fi

# Update path to include local files
[ "${PATH#*$HOME/scripts:}" == "$PATH" ] && export PATH="$HOME/scripts:$PATH"
[ "${PATH#*$HOME/.local/bin:}" == "$PATH" ] && export PATH="$HOME/.local/bin:$PATH"

# Update path to include homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Update path to include asdf
if [ -f ~/.config/asdf ] && [ -d ~/src/asdf ]; then
  export ASDF_CONFIG_FILE=~/.config/asdf
  export ASDF_DATA_DIR=~/src/asdf
  . $ASDF_DATA_DIR/asdf.sh
  . $ASDF_DATA_DIR/completions/asdf.bash

  export PATH="$PATH:$ASDF_DATA_DIR/installs/rust/stable/bin"
fi

# Update path to include mise
eval "$(/opt/homebrew/bin/mise activate bash)"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend
shopt -s cmdhist

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color|alacritty) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

. ~/scripts/git-prompt.sh

PROMPT_COMMAND="$PROMPT_COMMAND; history -a"

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Silence macos bash deprecation warning
export BASH_SILENCE_DEPRECATION_WARNING=1
export EDITOR="nvim"
export SHELL="/opt/homebrew/bin/bash"
export VISUAL="$EDITOR"

export SCRIPT_DIR="$HOME/.config/i3blocks"

. ~/scripts/z/z.sh

[ -f ~/.Xresources ] && command -v xrdb >/dev/null 2>&1 && xrdb -merge ~/.Xresources

stty -ixon

# Homebrew
if type brew &> /dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  [[ -f "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]] && source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
  done
else
  . /etc/bash_completion.d/git-prompt
fi

# Update once per week
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Fzf
if [ -f ~/.config/bash/fzf.bash ]; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --ignore-file .ignore_template'
  . ~/.config/bash/fzf.bash
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/nick/.local/share/google-cloud-sdk/path.bash.inc' ]; then . '/Users/nick/.local/share/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/nick/.local/share/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/nick/.local/share/google-cloud-sdk/completion.bash.inc'; fi

export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/.local/share/android-sdk
export ANDROID_NDK=$ANDROID_HOME/ndk/26.1.10909125
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
export PATH=$PATH:/Library/Apple/usr/bin

if [ -f "$HOME/.config/secrets" ]; then
  . ~/.config/secrets
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :
