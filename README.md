# Git Rebase (and run) Easy (GREasy)
## Jopra's GIT scripts - 2022

#### This is not an officially supported Google product

# Installation

```bash
git clone https://github.com/google/greasy.git ~/greasy
```

Additionally, add the following to your `.zshrc`:
```bash
[ -f ~/greasy/greasy.zsh ] && source ~/greasy/greasy.zsh || echo 'greasy is missing'
```

# Usage

GREasy provides a set of aliases for quick Git work: e.g.
```bash
a file # git add file
m "$MSG" # git commit -m "$MSG"
d # git diff
D # git diff --staged
gg # git grep
gl # git ls-files | grep
p # git push # (dual to P)
continue # git rebase --continue
skip # git rebase --skip
```

GREeasy also provides some more complex methods that make common tasks easy.
```bash
branch # gets the current branch name
#e.g.
git push origin $(branch)
```

```bash
P # git pull --rebase
P $branch # git checkout $branch; git pull --rebase
```

```bash
PA # git pull --rebase, but for ALL branches, pausing if there are merge conflicts.
```

```bash
ge "$PATTERN" # greps for "$PATTERN" and opens the results in your $EDITOR.
```

```bash
hub # opens the current repo's remote on the web, assuming it uses a 'github like' URL format.
```

```bash
edit # opens all the uncommited files in your $EDITOR.
last # opens all the files in the most recent commit in your $EDITOR.
```

```bash

run $CMD # attempts to run $CMD in the appropriate package/tooling for this project.
# See project_type in greasy.zsh for more details.

# Aliases:
r = run  # e.g. node / cargo
t = run test # node test / cargo test
b = run build # node build / cargo build
```

Checkout greasy.zsh for the full list of aliases and functions that GREasy makes available.

# Dependencies

- zsh
- git
- grep
- sed
- xargs

# Contributing

Please see the project's [code of conduct](./docs/code-of-conduct.md) and [contributing guide](./docs/contributing.md).

Feel free to join [GReasy's discussion group](https://groups.google.com/g/greasy)!

# License

Please see the project's [license](./LICENSE).
