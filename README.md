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

Checkout greasy.zsh for the list of aliases and functions that GREasy makes available.

# Dependencies

- depot_tools (can be installed via GREasy's `get_depot_tools` function)
  - python2
- zsh
- git
- grep
- sed
- xargs

# Contributing

Please see the project's [code of conduct](./docs/code-of-conduct.md) and [contributing guide](./docs/contributing.md).

# License

Please see the project's [license](./LICENSE).
