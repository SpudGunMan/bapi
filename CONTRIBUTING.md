Before contributing, Ensure any contributions align with ARRL philosophies and withiin FCC guidlines this software is Made in America.

Contributing to new apps or bapapp extentions

Before you start, consider if it would be better to contribute upstream if a patch to published build process. The issue you have may not be with a problem of this project and could be the orginal package. who will benefit from improvements to upstream software just like everyone else.

Clone the package repository into a new clean directory.

Setup a development environment. recomended to have a proper IDE like Atom Geany or vsCode to properly handle typo errors and tabulation. Additionally GitHub desktop or linking Atom or vsCode to github.com is a valuable time saver and git assistant.

Identify and clone the repository by running git clone < GITHUB.COM/DIR > < DEV/LOCATION/ > 

Create a new git branch with names like < patch- > or < enhance- > to avoid issues with upstream colision with issues. do this in the folder containing the package workspace from git clone.

Create a single pull request using git (git desktop is usefull at this stage) which contains the patch for all your suggested changes and files only the diff / changed or modified lines or files. 

Any out of scope file changes will be rejected or returned for correct submissions.

Email the patch url that adds the suggested package for consideration to groups.io for testing in the community
Include suggestions for which bundle(s) the package should be added to and any ideas for tests that may be of assistane.

Patching the menu

Please additionally test on all published supported hardware/distro, if adding a new architecture please be sure to have tested on at least one supported platform ideally a PI4 32 and 64bit

Reporting bugs and security concerns

Please submit any issues in upstream packages to their respective projects. Bugs or issues related to pi-build and bapi may be submitted here: https://github.com/KM4ACK/bapi/issues

Visit https://01.org/security for best practices on reporting security issues.

[1] Make sure your git user.name and git user.email are set as you wish as they may appear in public patch files.