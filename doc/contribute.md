Contributing to this branch of 2020 reboot
=============================================
[home of this effort on github is the TODO branch](https://SwissalpS.github.com/drawers/branch/)
[conventions we are striving toward](conventions.md)
[scratchpad of changes for migration](rewriteChanges.md)

Currently reviewers and advisors are most wanted help to this effort.

Goals
=========
* [ ] clean and maintanable code
* [ ] runs 'gently'
* [ ] result makes users, modders and admins happy
* [ ] seamless migration from older versions

Drawer Cabinet
----------------
* [x] add lock feature
* [x] move code away from entities so they are informative but not essential
    for drawers to work with tubes and other methods than manual.
* [x] 'realtime' update of count change in drawer infotext
* [ ] global toggle for experimentals to allow stacks of upgrades in cabinets. drawers.settings.cabinet_upgrade_stack_max = 4

Drawer Cabinet Pipeworks
-------------------------
* [x] insert from all 5 logical sides. So far it did and filled drawers from
    botom right to top left. SwissalpS likes the effect of the drawers filling
    up from the bottom reflecting how full the cabinet is.
* [x] tested with self contained injector
* [ ] tested with single/stack/digiline injectors into cabinet
* [ ] tested with single/stack/digiline injectors out of cabinet

Drawer Controller Digiline
-----------------------------
* [~] allow taking also when drawer is 100% full (need to rewrite controller code for one, but had it working on an upstream version)
* [ ] add command { command = 'has', name = 'mode:item' } that returns a boolean TODO figure out how exactly. bc next expansion requests will come

Drawer Controller Pipeworks
-----------------------------

Drawer Controller Node formspec
--------------------------------
* [ ] add slot(s) for stach(s) of upgrades which can be distributed to cabinets

