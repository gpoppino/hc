Introduction
============

Healthcheck is a script written in korn shell, awk and sed with the purpose of
testing different aspects of an Unix operating system and returning a status
code of success or failure for each one of these tests. This is useful to
quickly check for availability of services, file systems capacity thresholds,
etc.


Project structure
=================

The main script is called *main_healthcheck.sh* and it is used for local
execution of the script. For remote execution, the file *healthcheck.sh* is used
with the hostname to test as parameter (please, see **Instructions on how to use
the script**).

The file *healthcheck_lib* containts functions used by the different files
dedicated to distinct Unix platforms such as *healthcheck_linux*.

The files *healthcheck_linux* or *healthcheck_aix* hold the various checks
available for those platforms. If a new platform were to be added, its checks
file should be called healthcheck_*platform*, where *platform* is the name of
the platform returned by the command `uname`.

The directory *extensions/* containts files with checks that should be platform
independent.

Configuration files are named config.*platform* or config.general.
config.*platform* files list the checks that should be run for a specific
platform. Finally the file *config.general* contains options for the checks.
This file also contains variables that allow to group servers and checks
together, so that a group of servers are tested with specific checks. 


Coding conventions
==================

My .vimrc file is the following:

`
set textwidth=80
set tabstop=4
set shiftwidth=4
set expandtab
` 

Indentation is with spaces and tabs are 4 spaces. Lines larger than 80
characters should be wrapped with the `\` character.


Instructions on how to use the script
=====================================

Running the script
------------------

In order to run the script locally, run the following command:

`$ ksh main_healthcheck.sh`

> Note that some checks might need SUDO permissions if run as a regular user.

To run the script on another server, run the following command:

`$ ksh healthcheck.sh servername`

> The whole script is transferred to the remote server (called servername in
> this example) to the */tmp* directory via ssh and then removed after
> finishing.

Configuring the script
----------------------

In order to glue servers to checks, variables called *group_name_servers* and
*group_name_checks* need to be created. *name* is replaced by any string that
describes the group. *group_name_servers* should list the available servers,
whereas *group_name_checks* should list their checks.

A generic check list should be added to config.*platform*. These are run when no
group is found for a specific server.


Known issues
============

* Functions called *show_* still cannot be grouped by servers.
* check_network does not work under Ubuntu.

TODO
====

* Group *show_* functions with servers.
* Fix check_network to work under Ubuntu.


