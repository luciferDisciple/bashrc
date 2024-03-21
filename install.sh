#!/bin/bash

main() {
  install_file bashrc.sh "$HOME/.bashrc"  || return 1
  install_file inputrc   "$HOME/.inputrc" || return 1
}

install_file() {
  local source_path="$1"
  local destination_path="$2"
  if [[ -e "$destination_path" ]]; then
    ask_yes_no "File '$destination_path' already exists. Do you want to overwrite it?" \
      || return 1
  fi
  cp -f "$source_path" "$destination_path" || return 1
  log_info_line "Copied '$source_path' to '$destination_path'"
}

ask_yes_no() {
  local question="$1"
  while true; do
    log_info "$question [Y/n] "
    read
    [[ "$REPLY" =~ ^(|[Yy]|[Yy][Ee][Ss])$ ]] && return 0
    [[ "$REPLY" =~ ^([Nn]|[Nn][Oo])$ ]]      && return 1
  done
}

log_info() {
  echo -n "[install.sh] $*"
}

log_info_line() {
  echo "[install.sh] $*"
}

main && log_info_line "Success!" || log_info_line "Failed!"
