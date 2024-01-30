The menu json file has a simple structure.

Top level has menus by name.  You are required to have a menu called `main` as it is the first one that is executed.

Each menu consists of an array of choices, with a `display` item which is what is shown on the menu line.  And a `response` item that is what to do when this item is chosen.

Each response is required to have a `type` item, which can be `BASH`, `EXEC`, `MENU` or `TEMPMENU`.

* `BASH` consists of `commands` that is a list of lines that are put into a bash script and executed. After the commands are executed it returns to the menu.
* `EXEC` will execute a 1 line command which should be the full path to the command, the command is executed, it does not return to the menu.
* `MENU` displays the menu named what the element `menu` contains.
* `TEMPMENU` executes a BASH set of commands which needs to create a file called `tempmenu.json`.   That file is read in and that menu is displayed.  Note the menu does not have a menu name, just the list of choices.

