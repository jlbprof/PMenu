# PMenu
Command line (ncurses) Menu system for simple menu actions

# Getting Started
git clone this repo where you want to work on it.
Then

* `sudo ln -s /home/[username]/PMenu /opt/PMenu`
* `sudo ln -s /opt/PMenu/pmenu /usr/bin/pmenu`
* Using your package manager
..* Add ncurses and development library
..* Add gcc and other necessary tools for building programs
..* Install package `cpanm` a package manager for Perl
..* Install Curses, `Path::Tiny`, `File::chdir` with `cpanm`

In essence you want it located in `/opt/PMenu`

# To use `pmenu`
* Create a file in a directory called `pmenu.json`, then type `pmenu`.  That menu is executed.
* See Examples on the structure of the menu file.


