Contributing to this branch of 2020 reboot
=============================================
[[home of this effort on github is the rw2020beta0 branch](https://github.com/SwissalpS/drawers/tree/rw2020beta0)]

[[conventions we are striving toward](conventions.md)]

[[scratchpad of changes for migration](rewriteChanges.md)]

[[checklist for testers](checklist.md)]

Currently reviewers and advisors are most wanted help to this effort.

Goals
=========
* [ ] clean and maintanable code
* [ ] runs 'gently'
* [ ] result makes users, modders and admins happy
* [ ] seamless migration from older versions
* [ ] callbacks and hooks...

Drawer Cabinet
----------------
* [x] add lock feature.
* [ ] Should this be done with a tool or is it fine like this with key-comobo?
        Could use existing key tool(s)
* [x] move code away from entities so they are informative but not essential
        for drawers to work with tubes and other methods than manual.
* [x] 'realtime' update of count change in drawer infotext
* [ ] global toggle for experimentals to allow stacks of upgrades in cabinets.
        drawers.settings.cabinet_upgrade_stack_max = 4
* [x] allow removing unknown items really fast but don't allow putting them in drawers
* [x] don't allow players to put in bigger stacks into empty drawers than can't
        even fit on a stack of that item; let alone a drawer without upgrades.

Drawer Cabinet Pipeworks
-------------------------
* [x] insert from all 5 logical sides. So far it did and filled drawers from
    botom right to top left. SwissalpS likes the effect of the drawers filling
    up from the bottom reflecting how full the cabinet is.
* [x] tested with self contained injector
* [ ] tested with single/stack/digiline injectors into cabinet
* [ ] tested with single/stack/digiline injectors out of cabinet

Drawer Controller
------------------
* [ ] tested that does not include cabinets belonging to other players to network (maybe this is a feature)
* [ ] tested that can't access cabinets that are no longer connected
* [ ] tested that index is destroyed or updated when controller has been jumped with jumpdrive

Drawer Controller Digiline
-----------------------------
* [~] allow taking also when drawer is 100% full
* [ ] add command { command = 'has', name = 'mode:item' } that returns a
    boolean TODO figure out how exactly. bc next expansion requests will come
* [ ] give correct item no matter which orientation the cabinet and controller
    have to each other.
* [ ] tested with sonic screwdriver

Drawer Controller Pipeworks
-----------------------------

Drawer Controller Node formspec
--------------------------------
* [ ] add slot(s) for stack(s) of upgrades which can be distributed to cabinets

Drawer Compactor
-----------------
* [ ] have a working prototype
* [ ] define recipe
* [ ] figure out how it connects to the controller. Probably the controller
    needs to initiate the actions, that way it can distribute load to several
    compactors.
* [ ] does it go through a hard coded list sorted by priority of which items it
    should compact and how much to leave uncompacted or do we need to offer
    players options.

Translation
-------------
* [ ] move from intlib to
```lua
-- Minetest Translator
local S = minetest.get_translator("drawers")
```

Compatibility
----------------
* [ ] jumpdrive [[see](https://github.com/mt-mods/jumpdrive/blob/d836cc0569b26f1e155d7eb53cb1e1b13ad927da/move/move.lua#L148)]
* [ ] mesecons metrics [[see](https://github.com/minetest-monitoring/monitoring_drawers/tree/master)]

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTc1MzU4NTIwOF19
-->