Checklist for Testers
======================

Cabinet
--------
* [ ] shows up in crafting guide
* [ ] crafting works
* [ ] wielded image ok
* [ ] interact works (doors, machines) like bare hands
* [ ] place works
* [ ] dig works when empty
* [ ] dig works when full -> items and upgrades drop into world
perform these with empty drawers and with drawers that contain items
* [ ] sneak+right-click puts one wielded item in
* [ ] right-click puts wielded stack in
* [ ] right-click with empty hand puts rest from player inventory to drawer
* [ ] special+right-click locks the drawer to that item. (only when wielding correct item)
* [ ] special+left-click un-locks the drawer. (only when there is something to take out)
* [ ] sneak+left-click removes one item from drawer
* [ ] special+sneak+left-click un-locks taking one item out
* [ ] special+sneak+right-click locks putting one item in

* [ ] tag entity remains on empty but locked drawers
* [ ] tag entity vanishes on empty and un-locked drawers

* [ ] info text of tags is updated correctly

* [ ] attempting to put more items into an already full drawer takes no items
        from player and adds none to drawer and also does not fill other
        drawers of same cabinet (or other cabinets)

* [ ] drawers don't accept un-stackable items. If you find an item that holds
        meta information and drawers accept it, please open an issue on github.

Cabinet Tubes
---------------
Setup: place a line of tubes and place cabinets on, under and around the tubes.
    Assign items to some drawers, some locked some unlocked and a bunch empty.
    2x2s are best for this and other testes in general.
    Feed items into tubes. Make sure you are feeding from a direction that
    causes items to go from one cabinet to the next.

* [ ] drawers accept items from tubes from all sides except the front.
        (yes, there is a trick that works with any pipeworks node to get items
        in anyway, normal user behaviour can be assumed for this check.)

* [ ] info text of tags is updated correctly

* [ ] drawers don't accept un-stackable items. If you find an item that holds
        meta information and drawers accept it, please open an issue on github.

* [ ] all drawers of a cabinet are occupied before next cabinet is starting to fill
        opposed to how manual input only uses one drawer, the one player is
        interacting with

* [ ] locked drawers are respected correctly.

* [ ] stacks split correctly when overflowing into other drawers and cabinets

Cabinet upgrades
-----------------
* [ ] shows up in crafting guide
* [ ] crafting works
* [ ] wielded image ok
* [ ] interact works (doors, machines) like bare hands
* [ ] one per slot
* [ ] stackable in player inventory and chests but not in upgrade slots.
* [ ] shift-click works both ways
* [ ] calculates correctly even when mixed up types
* [ ] info text of tags updates correctly

Controller Basic
-----------------
* [ ] shows up in crafting guide
* [ ] crafting works
* [ ] wielded image ok
* [ ] interact works (doors, machines) like bare hands
* [ ] place works
* [ ] dig works when empty
* [ ] dig works when full -> items (and upgrades) drop into world

Controller Input
-----------------
these tests need to be done by inserting items through formspec and a second time
inserting them using tubes (e.g. self contained injector, digiline injector)
* [ ] items are accepted and any remainders are rejected
* [ ] info text of tags updates correctly
* [ ] locked drawers are respected correctly.
* [ ] stacks split correctly when overflowing into other drawers (and cabinets
        when 'use all cabinets' is checked)
* [ ] drawers don't accept un-stackable items.
* [ ] all drawers of a cabinet are occupied before next cabinet is starting to fill

Controller Output (digiline)
----------------------------
* [ ] channel field is only visible when digilines mod is also installed
* [ ] changing channel works using formspec
* [ ] reading channel works with channel copier [digistuff]
* [ ] setting channel works with channel copier [digistuff]
* [ ] outputs correct items
* [ ] outputs correct count (what was asked for, a legal full stack or all that was there)
* [ ] info text of tags updates correctly
* [ ] locked drawers are respected correctly.
* [ ] in use all mode items are gathered from any cabinet that has them
* [ ] not in use all: items are gathered from one cabinet only but may
        come from multiple drawers of the same cabinet

Trim
------
* [ ] shows up in crafting guide
* [ ] crafting works
* [ ] wielded image ok
* [ ] place works
* [ ] dig works
* [ ] trim, cabinets, controllers (and compactors) connect in same fashion
        as backbones of jumpdrive.
* [ ] radius 14 is respected correctly

--[[
Compactor Basic
-----------------
* [ ] shows up in crafting guide
* [ ] crafting works
* [ ] wielded image ok
* [ ] interact works (doors, machines) like bare hands
* [ ] place works
* [ ] dig works when empty
* [ ] dig works when full -> items (and upgrades) drop into world
--]]

Jumpdrive
----------
* [ ] no entities left behind
* [ ] all entities appear at new location
* [ ] all contents and settings are correct

Migration
----------
* [ ] old drawer setups migrate correctly to new version

