# dotfiles

A collection of configuration files and scripts.

## Usage

```
./install.sh config/basic 
```

## Design

The dotfiles are split into multiple categories.
A category is represented by a folder.
A category may have sub-categories.
The files within a category mirrors the structure within the home directory.
The name of directories and files ("action") determine their purpose:

* A directory without a special suffix is a category.
* A sub-category with suffix `.install` will be installed automatically with its parent.
* A `install.sh` script will be installed automatically with its parent, too.
* A directory with suffix `.dir` creates a directory. Its sub-actions are executed within the created directory.
* A file with suffix '.symlink' will create a symbolic link to that file.

## Categories

* basic: configuration files for all machines
* terminal: other files for command line
* terminal-zsh: setting up zsh
* dev: related to development
* desktop: desktop environment
  * xfce
  * yakm

## Testing

Several scripts provide a way to simulate a new session. This allows to test the installation of the configuration files.

* `test/su.sh`: Starts a terminal session with the `su` command as a temporary user.
* `test/xephyr.sh`: Starts a nested X session using the `dm-tool`, and logging in as a temporary user.



