#!/usr/bin/env bash

# encryption: https://www.gnupg.org/gph/en/manual.html#AEN111
# git hooks: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
# adding files to git on pre_commit hook:
# http://stackoverflow.com/questions/3284292/can-a-git-hook-automatically-add-files-to-the-commit


function _check_setup {
  # Checking git and secret-plugin setup:
  if [[ ! -d ".git" ]] || [[ ! -d ".git/hooks" ]]; then
    _abort "repository is broken. try running 'git init' or 'git clone'."
  fi

  # Checking gpg setup:
  local secring="$SECRETS_DIR_KEYS/secring.gpg"
  if [[ -f $secring ]] && [[ -s $secring ]]; then
    # secring.gpg is not empty, someone has imported a private key.
    _abort "it seems that someone has imported a secret key."
  fi
}


function _init_script {
  # checking for proper set-up:
  _check_setup

  if [[ $# == 0 ]]; then
    usage "no input parameters provided."
  fi

  # load dependencies:
  # for f in ${0%/*}/src/*/*; do [[ -f "$f" ]] && . "$f"; done

  # routing the input command:
  if [[ `_function_exists $1` == 0 ]] && [[ ! $1 == _* ]]; then
    $1 "${@:2}"
  else
    usage "command $1 not found."
  fi
}

set -e
_init_script $@
