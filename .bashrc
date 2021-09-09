#
# ~/.bashrc
#

[[ $- != *i* ]] && return

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

# If git is istalled and working directory is inside of git repository, show
# repository info at the command line prompt

GIT_PROMPT_SCRIPT=/usr/share/git/completion/git-prompt.sh
[[ -f "$GIT_PROMPT_SCRIPT" ]] && git_available=true
if ${git_available} ; then
	source "$GIT_PROMPT_SCRIPT"
	git_info_mono='$(__git_ps1 "(%s)")'
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
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W '${git_info_color}'\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W '${git_info_color}'\[\033[01;32m\]]\$\[\033[00m\] '
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
unset git_available GIT_PROMPT_SCRIPT

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less

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

alias e=nvim
alias vim=nvim
alias ll='ls -l --group-directories-first'
alias to-utf-8='iconv -f CP1250 -t UTF8'

EDITOR=nvim
GIT_EDITOR=nvim

BC_ENV_ARGS=~/.bc
export BC_ENV_ARGS

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

export PATH="$HOME/.symfony/bin:$PATH"
