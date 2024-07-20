#
# ~/.bashrc
#

[[ $- != *i* ]] && return

command.is.available() {
	which "$1" &>/dev/null
}

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export BC_ENV_ARGS="$HOME/.bc"
export EDITOR=nvim
export GEM_HOME="$(command.is.available ruby && ruby -e 'puts Gem.user_dir')"
export GIT_EDITOR=nvim

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias e="$EDITOR"
alias free='free -m'                      # show sizes in MB
alias more=less
alias np='nano -w PKGBUILD'
alias vim="nvim"

is_path_set=${is_path_set:-false}
if ! $is_path_set; then
  export PATH="$HOME/.local/bin:$PATH"
  export PATH="$HOME/.symfony/bin:$PATH"
  export PATH="$GEM_HOME/bin:$PATH"
  export is_path_set=true
fi

colors() {
  local fgc bgc vals seq0

  printf "Color escapes are %s\n" '\e[${value};...;${value}m'
  printf "Values 30..37 are \e[33mforeground colors\e[m\n"
  printf "Values 40..47 are \e[43mbackground colors\e[m\n"
  printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

  # foreground colors
  for fgc in {30..37}; do
    # background colors
    for bgc in {40..47}; do
      fgc=${fgc#37} # white
      bgc=${bgc#40} # black

      vals="${fgc:+$fgc;}${bgc}"
      vals=${vals%%;}

      seq0="${vals:+\e[${vals}m}"
      printf "  %-9s" "${seq0:-(default)}"
      printf " ${seq0}TEXT\e[m"
      printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
    done
    echo; echo
  done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
  xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
    ;;
  screen*)
    PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
  && type -P dircolors >/dev/null \
  && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

# ANSI Escape Sequences

ANSI_RESET='\033[00m'
BOLD='\033[01m'
ITALIC='\033[03m'
UNDERLINE='\033[04m'

RED='\033[31m'    ; ON_RED='\033[41m'
GREEN='\033[32m'  ; ON_GREEN='\033[42m'
YELLOW='\033[33m' ; ON_YELLOW='\033[43m'
BLUE='\033[34m'   ; ON_BLUE='\033[44m'
PINK='\033[35m'   ; ON_PINK='\033[45m'
CYAN='\033[36m'   ; ON_CYAN='\033[46m'

# The following print the same:
# echo -e "${UNDERLINE}${RED}warning!${ANSI_RESET}"
# echo -e "\e[04m\e[31mwarning!\e[00m'
# echo -e "\e[04;31mwarning!\e[00m'
# echo -e "\033[04;31mwarning!\033[00m'
# echo $'\033[04;31mwarning!\033[00m'
# 033 == 27 == 0x1B == ASCII("ESCAPE")

bold () {
  local text
  if [[ $# -eq 0 ]]; then
    IFS= read -d '' -r text
  else
    text="$@"
  fi
  echo -ne "${BOLD}${text}${ANSI_RESET}"
}

underline () {
  local text
  if [[ $# -eq 0 ]]; then
    IFS= read -d '' -r text
    # read stdin if no args ('IFS=' keeps whitespace)
  else
    text="$@"
  fi
  echo -ne "${UNDERLINE}${text}${ANSI_RESET}"
}

italics () {
  local text
  if [[ $# -eq 0 ]]; then
    IFS= read -d '' -r text
  else
    text="$@"
  fi
  echo -ne "${ITALIC}${text}${ANSI_RESET}"
}

center () {
  local text
  if [[ $# -eq 0 ]]; then
    IFS= read -d '' -r text
  else
    text="$@"
  fi
  local screen_width=${COLUMNS:-80}
  local lpadding=$[($screen_width - ${#text})/2]
  printf '%*s' $[$lpadding + ${#text}] "$text"
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# If git is istalled and working directory is inside of git repository, show
# repository info at the command line prompt

__git_ps1_available=false
git_ps1_sources=(
  /usr/share/git/completion/git-prompt.sh
  /usr/share/bash-completion/bash_completion
  /etc/bash_completion
)
for file in "${git_ps1_sources[@]}"; do
  if [[ -r "$file" ]]; then
    source "$file"
    __git_ps1_available=true
    break
  fi
done
if $__git_ps1_available; then
  git_info_mono='$(__git_ps1 " (%s)")'
  git_info_color='\['${BOLD}${RED}'\]'${git_info_mono}'\['${ANSI_RESET}'\]'
  # CAUTION: ANSI Control Squences in PS1 must be surrounded with
  #          '\[' and '\]'
  #          see: section PROMPTING in bash(1) manpage
fi

if ${use_color} ; then
  # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
  if type -P dircolors >/dev/null ; then
    if [[ -f ~/.dir_colors ]] ; then
      eval $(dircolors -b ~/.dir_colors)
    elif [[ -f /etc/DIR_COLORS ]] ; then
      eval $(dircolors -b /etc/DIR_COLORS)
    fi
  fi

  if [[ ${EUID} == 0 ]] ; then
    PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W'${git_info_color}'\[\033[01;31m\]]\$\[\033[00m\] '
  else
    PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W'${git_info_color}'\[\033[01;32m\]]\$\[\033[00m\] '
  fi

  alias ls='ls --color=auto'
  alias grep='grep --colour=auto'
  alias egrep='egrep --colour=auto'
  alias fgrep='fgrep --colour=auto'
else
  if [[ ${EUID} == 0 ]] ; then
    # show root@ when we don't have colors
    PS1='\u@\h \W '${git_info_mono}'\$ '
  else
    PS1='\u@\h \w '${git_info_mono}'\$ '
  fi
fi

unset use_color safe_term match_lhs sh
unset __git_ps1_available GIT_PROMPT_SCRIPT

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

alias ll='ls -l --group-directories-first'
alias to-utf-8='iconv -f CP1250 -t UTF8'

function yt2mp3 () {
  youtube-dl -f bestaudio --extract-audio --audio-format mp3 \
    -o "$1.%(ext)s" $2
}

bitrate () 
{ 
  local file="$1"
  echo "$file"
  _song_bitrate "$file"
  shift
  while [[ -n "$1" ]]; do
    local file="$1"
    printf "\n$file\n"
    _song_bitrate "$file"
    shift
  done
}

_song_bitrate ()
{
  ffmpeg -hide_banner -i "$1" 2>&1 |
    grep --colour=never 'bitrate: [0-9]\+ kb/s' |
    sed -E 's/, start: 0.000000//; s/^\W+//'
}

shortcuts () {

  local shortcuts_doc
IFS= read -d '' shortcuts_doc <<EOF


`center  'BASH SHORTCUTS | LINE EDITING COMMANDS' | bold`

`italics NOTATION`:
C-x means CTRL+X
M-x means ALT+X or ESC and then X

`underline shell-expand-line` (M-C-e)
(That's why bash is great) Perform expansions on the current line without
executing the command, meaning for example, all variable references are
substituted for the values these variables store.

`underline clear-screen` (C-l)
Clear the screen leaving the current line at the top of the screen. With an
argument, refresh the current line without clearing the screen.

`underline beginning-of-line` (C-a)
Move to the start of the current line.

`underline end-of-line` (C-e)
Move to the end of the line.

`underline forward-word` (M-f)
Move forward to the end of the next word.  Words are composed of alphanumeric
characters (letters and digits).

`underline backward-word` (M-b)
Move  back  to the start of the current or previous word.  Words are composed
of alphanumeric characters (letters and digits).

`underline digit-argument` (M-0, M-1, ..., M--)
Add this digit to the argument already accumulating, or start a new argument.
M-- starts a negative argument.

`underline undo` (C-_, C-x C-u)
Incremental undo, separately remembered for each line.

`underline revert-line` (M-r)
Reset a line from the history, i.e. discard all edits you have made.

`underline kill-line` (C-k)
Remove all characters from the cursor to the end of line. Removed characters
are stored in kill ring (clipboard).

`underline unix-line-discard` (C-u)
Remove all characters form the beginning of the line to the end of the line.
Removed characters are stored in kill ring (clipboard).

`underline yank` (C-y)
Paste (yank) the content of the clipboard (kill-ring).

`underline abort` (C-g)
Use it to cancel `underline reverse-history-search` command.

`underline end-of-history` (M->)
Jump to the last line in the history, i.e. edit the newest, current command.
CTRL+SHIFT+.

`underline insert-last-argument` (M-.)
Insert the last command line argument (word) used. Executing multiple times
fetches words from further back in history.

`underline transpose-words` (M-t)
Swap last two words of the current line.

`underline edit-and-execute-command` (C-xC-e)
Invoke an editor on the current command line, and execute the result as shell
commands. Bash attempts to invoke \$VISUAL, \$EDITOR, and emacs as the editor,
in that order.
EOF

  echo "$shortcuts_doc" | less --raw-control-chars
}

is_func_declared ()
{
  case "$1" in
    -h|--help)
      echo 'usage: is_func_declared [-h|--help] NAME'
      echo ''
      echo 'Test if function NAME is defined.'
      echo ''
      echo 'optional arguments:'
      echo '  -h, --help     show this help and exit'
      echo ''
      echo 'positional arguments:'
      echo '  NAME    name of a bash function'
      return 2;;
    -*)
      echo is_func_declared: unknown option: $1
      return 3;;
    *)
      local name="$1"
      test $(declare -F "$name") = "$name"
      return;;
  esac
}

path_pretty ()
{
  case "$1" in
    -h|--help)
      echo 'usage: path_pretty [-h|--help]'
      echo ''
      echo 'Print the value of PATH environment variable, but with each directory on'
      echo 'a separate line.'
      echo ''
      echo 'optional arguments:'
      echo '  -h, --help     show this help and exit'
      return 2;;
  esac
  echo "$PATH" | sed 's/:/\n/g'
}

cdwin ()
{
  case "$1" in
    -h|--help)
      echo 'usage: cdwin [-h|--help] WINPATH'
      echo ''
      echo 'Assuming you run Windows Subsystem for Linux, change current directory'
      echo 'to a directory where a Windows folder specified by WINPATH is mounted at.'
      echo ''
      echo 'positional arguments:'
      echo "  WINPATH    path of a Windows folder, eg. 'C:\Users\adam\Desktop'"
      echo '             Enclose it within single quotes. To learn why, execute:'
      echo '             echo C:\I\dont\quote\properly'
      echo ''
      echo 'optional arguments:'
      echo '  -h, --help     show this help and exit'
      return 2;;
  esac
  local win_path="$1"
  local unix_path=$(sed -e 's:\\:/:g' -e "s/^\([A-z]\):/\L\1/" -e "s:^:/mnt/:" <<< "$1")
  cd "$unix_path" \
    || echo '[cdwin] Could not go to requested folder.' \
            'Did you remember to enclose WINPATH in single quotes?'
}

timestamp ()
{
  date '+%Y%m%d%H%M%S'
}

newest_file () 
{ 
    # doesn't work if newline character is present anywhere
    local dir="${1%/}"
    local file_basename="$(ls -t "$1" | head -1)"
    echo "${dir}/${file_basename}"
}
