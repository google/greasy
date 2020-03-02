# Git Rebase Easy (GREasy)
# Jopra@'s little git scripts

HOME="`cd;pwd`"

# Installs Chrome's very handy depot management tools.
# Probably not particularly useful for all devs, but may help.
function get_depot_tools() {
  # https://dev.chromium.org/developers/how-tos/install-depot-tools
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git ~/depot_tools
}

if [[ -d "$HOME/depot_tools" ]]; then
  export PATH="$PATH:$HOME/depot_tools"
fi

# Creates temporary commits (this is roughly equivalent to `git stash`, but instead of stashing to
# the git stash it stashes to the current branch.
function mtmp() {
  if [[ -z $1 ]]; then
    MSG=""
  else
    MSG=" - $@"
  fi
  git commit -m "TMP$MSG - added" --no-verify
  git add --all
  git commit -m "TMP$MSG - modified" --no-verify
}

# Un-does an `mtmp` `git stash pop`.
# Note: This will not fail if there are no tmp commits, it will log and continue.
function unmtmp() {
  fst="$(git log | head -n 1 | grep ' TMP - ')"
  if [[ -z $fst ]]; then
    echo 'No tmps found'
  else
    git reset 'HEAD~'
    git stash
    snd="$(git log | head -n 1 | grep ' TMP - ')"
    if [[ -z $fst ]]; then
      echo 'One tmp found'
    else
      git reset 'HEAD~'
      git add --all
    fi
    git stash pop
  fi
}

# Checks out a branch and rebases against the parent branch
# Optional argument is which branch to checkout (otherwise the current branch will be used).
function P(){
  if [[ -z $1 ]]; then
  else
    git checkout "$1"
  fi
  git pull --rebase
}

# Auto completer for P
# Can be used with zsh's `compdef _P P`
_P() {
  branches=($(git branch --no-column --no-color -a | sed "s/[ *] //"))
  compadd -l -a -- branches
}

# Just like P, but for all branches and fetches the upstream.
# Should be used regularly to ensure that all branches are up to date with the upstream.
# (Requires depot_tools)
function PA(){
  git fetch
  for branch in $(git map-branches --no-color | grep "  " | sed "s/[ *]*//g")
  do
    echo "Pulling $branch"
    P $branch
  done
}

# Grep for lines stored in git
alias gg="git grep"
# Grep for files stored in git
alias gl="git ls-files | grep"
# Takes the output from gg or gl and opens each file in your editor of choice.
# Example: `gg " wat " | ge` will open all files stored in git containing ' wat '.
function ge() {
  grep "[/\\\.]" | sed "s/.*-> //" | sed "s/:.*//" | sed "s/ *|.*//" | sort | uniq | xargs "$EDITOR"
}

# Shows all git branches (works best with depot_tools)
alias map="(git status 1&> /dev/null 2&>/dev/null && (git map-branches -v || git branch -vv)) || ls"

# Shortenings for common git commands
alias continue="git rebase --continue || git merge --continue"
alias skip="git rebase --skip"
alias checkout="git checkout"

# Single letter shortenings for extremely common git commands
alias s="/usr/bin/clear && git status -sb 2> /dev/null"
alias a="git add"
alias m="git commit -m "

# Show all changes
alias d="git diff --diff-algorithm=patience"

# Show all staged changes
alias D="git diff --staged --diff-algorithm=patience"

# Attempt to push your changes to whichever git back end is in use.
alias p="git push || git cl upload || repo upload ."
