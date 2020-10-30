coding conventions for drawers mod 2020 reboot
===============================================
This document covers *.lua files, it does not apply to documentation files.
Please note, this is directed at maintainers, for PRs we welcome if they already
conform to these standards but it is not a condition. We rather hear from your
bright idea, than to miss it because you didn't have time to clean up your code.
It can however speed up the process if you did follow these guidlines.

Terms
-------
**cabinet**: the node that has 1, 2 or 4 drawers in it and up to five upgrades.

**drawers**: the name of this mod but also refers to multiple compartments in a
    cabinet.

**drawer**: one compartment that holds items. Each drawer has a number of slots
    available. The amount of slots depends on upgrades and if MC-clone mod is used.
    The total amount of items a drawer can hold, depends on the item's max stack
    size (cobble = 99, minegeld = 65535), and the amount of slots.

**tag**: this is the entity that displays texture and infotext of a drawer.
    It is also used for manual player interactions.

**controller**: this node manipulates a network of cabinets. There can be multiple
    controllers in the same cabinet network. They offer a digiline interface
    and also take items from tubes and formspec inventory.

**compactor**: this node makes blocks from ingots and in case of coal, clay and sulfur
    from lumps too. May also add honey, cobbles and dirt.

Whitespace
-----------
* Use tabs and don't mix with spaces. (Tab width = 4)
* Use single quotes for strings unless the quotes are client facing.
* Prefered doted table indexes wherever possible. Avoiding verbose t['abc'] style.
  to achieve this we avoid special characters in field names
* No space after '(' or before ')'
* Yes space after '{ ' and before ' }' prefer more lines than long lines
* Closing '}' of multiline tables go on own line, horizontally aligned with
  line indentation of line that opened table.

Variable naming
----------------
* Use descriptive_names_in snake.
* You may use micro names in tight loops. put an effort to not use them.
* Micro names are ok in other situations if they are reference to often used
  globals, hence in the list below. `Reserved Names`_

Reserved Names
---------------
Thes variable names *MUST* always point to same point in global table. Through
all scopes *dc* is short for *drawers.cabinet* and so forth.
You should prefer the long form.
For code readability despite these abreviations, we declare them locally at top
of files and may also be re-referenced in sub scopes if it helps keep code clear.
Don't use abreviated form when it's not needed and makes code confusing.
Important is, that they are not used for anything else.

TODO: discuss if 2 letters are maybe too short?
actually just don't unless really awfull code if not used.

Short     Medium       Original
dc        dcab         drawers.cabinet
dg        dgui         drawers.gui
ds        dset         drawers.settings
dl        dcont        drawers.controller
dt        dtag         drawers.tag
dtk       dtkeys       drawers.tag.meta_keys
du        dupg         drawers.upgrade

other reserved variable names:
id                refers to a drawer / tag id in numerical form
tag_id            same as id but may be a string
pos               not to be used unless it's ambiguous what it is position of
                  e.g. contains_pos() and is_same_pos() functions
pos_node          is to be used when node can be trim, cabinet, controller or compactor
pos_cabinet       always used for cabinet coordinates
pos_controller    always used for controller coordinates
pos_compactor     always used for compactor coordinates
index             numerical index in lists / tables

Object Structur
---------------
TODO: if somebody wants to go through with maintaining this structur .... go ahead.


File Names
-----------
* use cammelCase and no special characters, only a-Z and 0-9.
* try to keep them informative of what they do using directory tree as help.

If and .. or .. then ... end Code Blocks
------------------------------------------
if you really need to do this and it is well readable then ok. If it is with
long expressions, use multiple lines and put the verb at beginning of new line.
E.g better:
```lua
if some_long_state_expression
  and some_other_context
  and yet_another_option
then
  --do something
end
```
than:
```lua
if some_long_state_expression and some_other_context and yet_another_option then
  --do something
end
```
It's cleaner to read and easier to uncomment an expression to test out.
Also this allows to add comments nicely.

Switch Blocks
---------------
When doing if .. elseif .. elseif .. end switch replacement and also in other
situations, put the most important expression to the left so it can be used as
index when reading code:
```lua
if 'programm' == some_variable then
  --  ...
elseif 'exit' == some_variable then
  -- ...
end
```
some_variable is on every line, so it says least about which code is run if it
is satisfied. However the static and least vunerable strings say a lot about
what is about to happen.
This habit has many good side-effects.
E.g. if a '=' instead of '==' typo slips in, you get a warning right away.
if opposite order is used ``some_variable = 'exit'``, and same typo happens
you may not realize until long after you have been searching for bug in other
areas of code.

Try and write code that fails in a way that helps debug it.


do this:
```lua
def.tube.insert_object = def.tube.insert_object
  or drawers.cabinet.insert_object_from_tube

def.tube.can_insert = def.tube.can_insert
  or drawers.drawer_can_insert_stack_from_tube
```
not this:
```lua
def.tube.insert_object = def.tube.insert_object
  or drawers.cabinet.insert_object_from_tube
def.tube.can_insert = def.tube.can_insert
  or drawers.drawer_can_insert_stack_from_tube
```
empty lines are good in these cases. There are exceptions to this empty line rule.


while ... do ... end
=====================
Avoid ``while`` loops, prefer ``repeat ... until ...`` loops.
If you find yourself doing this:
```lua
for _, v in ipairs(table) do
  -- something
end
```
You probably can achieve the same with a ``repeat`` loop:
```lua
local v
local i = #table
repeat
  v = table[i]
  -- something
  i = i - 1
until 0 == i
```

Yes, it's more to write, but in this mod we should try and be gentle as
users will soon have huge storages built with drawers and controllers.

