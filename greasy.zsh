#!/bin/zsh -eu
#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Git Rebase (and run) Easy (GREasy)

# Installs Chrome's very handy depot management tools.
# https://dev.chromium.org/developers/how-tos/install-depot-tools
HOME="$(cd;pwd)"
DEPOT_TOOLS="$HOME/depot_tools"
function get_depot_tools() {
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "$DEPOT_TOOLS"
}
if [[ -d "$DEPOT_TOOLS" ]]; then
  export PATH="$PATH:$DEPOT_TOOLS"
fi

# 'Stash' changes on the current branch using temporary commits. Roughly eq to `git stash`.
function mtmp() {
  MSG=" - $*"
  if [[ -z $1 ]]; then
    MSG=""
  fi
  git commit -m "TMP$MSG - added" --no-verify
  git add --all
  git commit -m "TMP$MSG - modified" --no-verify
}

# Un-does an `mtmp` roughly eq to `git stash pop`.
function unmtmp() {
  fst="$(git log | head -n 1 | grep ' TMP - ')"
  if [[ -z $fst ]]; then
    echo 'No tmps found'; return
  fi
  git reset 'HEAD~'
  git stash
  git log | head -n 1 | grep ' TMP - '
  if [[ -n $fst ]]; then
    git reset 'HEAD~'
    git add --all
  fi
  git stash pop
}

function fetch_all() {
  for r in $(git remote); do
    git fetch "$r"
  done
}

# Checks out a branch and rebases against the parent branch.
# Optional argument is which branch to checkout (otherwise the current branch will be used).
function P() {
  fetch_all
  if [[ -n $1 ]]; then
    git checkout "$1"
  fi
  git pull --rebase
}

# Auto completer for P. Can be used with zsh's `compdef _P P`.
_P() {
  export branches=($(git branch --no-column --no-color -a | sed "s/[ *] //"))
  compadd -l -a -- branches
}

# Just like P, but for all branches and fetches the upstream. Note: Requires depot_tools.
function PA() {
  fetch_all
  from_branch=$(branch)
  for r in $(git remote); do
    git fetch "$r"
  done
  for b in $(git branch --no-color | sed "s/^[* ]*//"); do
    echo "Pulling $b"
    P "$b" || return 1
  done
  git checkout "$from_branch"
}

# Returns the current branch for short commands like `git push origin $(branch) -f`.
alias branch="git branch --color=never | grep '\*' | sed 's/* \(.*\)$/\1/' | sed 's/(HEAD detached at [^\/]*\///' | sed 's/)//' | head -n 1"
# Shows all git branches (works best with depot_tools).
alias map="(git status 1&> /dev/null 2&>/dev/null && git --no-pager branch -vv) || ls"
alias continue="git rebase --continue || git merge --continue"
alias skip="git rebase --skip"

# Easy cloning
alias -s git='git clone'

# Grep for git for:
alias gg="git grep" # lines
alias gl="git ls-files | grep" # files
# Takes the output from gg or gl and opens each file in your editor of choice.
# Example: `gg " wat " | ge` will open all files stored in git containing ' wat '.
function ge() {
  grep "[/\\\.]" | sed "s/.*-> //" | sed "s/:.*//" | sed "s/ *|.*//" | sort | uniq | xargs "$EDITOR"
}
# List authors
alias ga="git ls-files | while read f; do git blame --line-porcelain \"\$f\" | grep \"^author \" | sed \"s/author //\"; done | sort -f | uniq -ic | sort -n"
# Rename a branch
alias gm="git branch -m"
# Single letter shortenings for extremely common git commands
alias s="git status -sb 2> /dev/null || ls"
alias a="git add"
alias m="git commit -m "
alias d="git diff --diff-algorithm=patience"
alias D="git diff --staged --diff-algorithm=patience"
alias p="git push"

function hub() {
  remote=$(git remote -v | grep origin | tr '\t' ' ' | cut -f2 -d' ' | head -n1)
  xdg-open "$(echo "$remote" | sed "s|git@|http://|" | sed "s/com:/com\\//")"
}
alias edit="git status --porcelain | sed \"s/^..//\" | xargs \$EDITOR"
alias last="git diff HEAD~1 --raw | grep -o '[^ ]*$' | sed 's/^..//' | sed \"s/.*->//\" | xargs \$EDITOR"

function __run() {
  declare -A project_type=( ["package.json"]="npm run" ["cargo.toml"]="cargo" ["Cargo.toml"]="cargo" ["run.sh"]="./run.sh" ["BUILD"]="blaze")

  for config_file manager in ${(kv)project_type}; do
    if [[ -f "./$config_file" ]]; then
      echo "${manager} @ $(pwd)"
      eval "$manager $*"
      exit
    fi
  done
  if [ "$(pwd)" = "/" ]; then
    echo "<Unknown project>" && exit 1
  fi
}
function run() {(
  while true; do
    __run "$@"; cd ".."
  done
)}

alias r="run"
alias t="run test"
alias b="run build"
