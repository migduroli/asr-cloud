#!/bin/bash

colored_text() {
  color=`tput setaf $1`
  reset=`tput sgr0`
  shift
  echo "${color}$@${reset}"
}

red_text() {
  colored_text 1 "$@"
}

green_text() {
  colored_text 2 "$@"
}
